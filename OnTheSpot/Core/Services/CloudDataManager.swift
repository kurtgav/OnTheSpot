import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

class CloudDataManager: ObservableObject {
    static let shared = CloudDataManager()
    
    @Published var locations: [Location] = []
    @Published var activePlans: [Plan] = []
    @Published var currentChatMessages: [ChatMessage] = []
    @Published var hiddenSpotIds: [String] = []
    @Published var blockedUserIds: [String] = []
    
    private let db = Firestore.firestore()
    
    private init() {
        startListening()
    }
    
    // --- 1. SPOTS ---
    func startListening() {
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).addSnapshotListener { doc, _ in
                if let data = doc?.data(), let hidden = data["hiddenSpots"] as? [String] {
                    self.hiddenSpotIds = hidden
                }
            }
        }

        db.collection("spots").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let allSpots = documents.compactMap { doc -> Location? in
                try? doc.data(as: Location.self)
            }
            
            self.locations = allSpots.filter { !self.hiddenSpotIds.contains($0.id.uuidString) }
        }
    }
    
    func addLocation(_ location: Location) {
        try? db.collection("spots").document(location.id.uuidString).setData(from: location)
        incrementStat(field: "spotsAdded") // Update Stat
    }
    
    func updateStatus(for location: Location, newStatus: LocationStatus) {
        db.collection("spots").document(location.id.uuidString).updateData([
            "currentStatus": newStatus.rawValue,
            "lastUpdate": Date()
        ])
        incrementStat(field: "points", amount: 10) // Update Stat
    }
    
    func deleteLocation(_ location: Location) {
        db.collection("spots").document(location.id.uuidString).delete()
    }
    
    func hideLocation(spotId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Add ID to user's "hiddenSpots" array in Firebase
        db.collection("users").document(uid).updateData([
            "hiddenSpots": FieldValue.arrayUnion([spotId])
        ]) { error in
            if error == nil {
                // Remove locally immediately for snappy UI
                self.locations.removeAll { $0.id.uuidString == spotId }
            }
        }
    }
    
    // --- 2. USER PROFILE & STATS ---
    func saveUserProfile(name: String, bio: String, location: String, tags: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData: [String: Any] = [
            "name": name,
            "bio": bio,
            "location": location,
            "tags": tags, // New
            "points": DataManager.shared.contributionPoints
        ]
        db.collection("users").document(uid).setData(userData, merge: true)
        
        // Update Local
        DataManager.shared.userName = name
        DataManager.shared.userBio = bio
        DataManager.shared.userLocation = location
        DataManager.shared.userTags = tags
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).addSnapshotListener { document, _ in
            guard let data = document?.data() else { return }
            DispatchQueue.main.async {
                DataManager.shared.userName = data["name"] as? String ?? "User"
                DataManager.shared.userBio = data["bio"] as? String ?? "Rookie"
                DataManager.shared.userLocation = data["location"] as? String ?? "Unknown"
                
                // 🔥 SYNC STATS
                DataManager.shared.contributionPoints = data["points"] as? Int ?? 0
                DataManager.shared.spotsAdded = data["spotsAdded"] as? Int ?? 0
            }
        }
    }
    
    func incrementStat(field: String, amount: Int = 1) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).updateData([
            field: FieldValue.increment(Int64(amount))
        ])
    }
    
    // --- 3. PLANS & CHAT ---
    func createPlan(_ plan: Plan) {
        try? db.collection("plans").addDocument(from: plan)
    }
    
    func listenForPlans(at locationId: String) {
        db.collection("plans").whereField("locationId", isEqualTo: locationId)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.activePlans = docs.compactMap { doc -> Plan? in
                    var p = try? doc.data(as: Plan.self)
                    p?.id = doc.documentID
                    return p
                }
            }
    }
    
    func joinPlan(_ plan: Plan) {
        guard let uid = Auth.auth().currentUser?.uid, let planId = plan.id else { return }
        db.collection("plans").document(planId).updateData(["participants": FieldValue.arrayUnion([uid])])
    }
    
    func leavePlan(_ plan: Plan) {
        guard let uid = Auth.auth().currentUser?.uid, let planId = plan.id else { return }
        db.collection("plans").document(planId).updateData(["participants": FieldValue.arrayRemove([uid])])
    }
    
    func deletePlan(_ plan: Plan) {
        guard let planId = plan.id else { return }
        db.collection("plans").document(planId).delete()
    }
    
    // 🔥 THIS IS THE REAL-TIME ENGINE
    func listenToChat(planId: String) {
        db.collection("plans").document(planId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                
                // This updates the variable INSTANTLY when DB changes
                DispatchQueue.main.async {
                    self.currentChatMessages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
                }
            }
    }
    func sendMessage(planId: String, text: String) {
        guard let user = Auth.auth().currentUser else { return }
        let msg = ChatMessage(
            id: UUID().uuidString,
            senderId: user.uid,
            senderName: DataManager.shared.userName, // Use locally cached name
            text: text,
            timestamp: Date()
        )
        try? db.collection("plans").document(planId).collection("messages").addDocument(from: msg)
    }
    
    // Helper
    func binding(for id: UUID) -> Binding<Location>? {
        guard let index = locations.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(get: { self.locations[index] }, set: { self.locations[index] = $0 })
    }
    
    func sendImageMessage(planId: String, image: UIImage) {
       guard let user = Auth.auth().currentUser else { return }
       
       // Convert to Base64 String (Limit size for Firestore)
       guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
       let imageString = imageData.base64EncodedString()
       
       let msg = ChatMessage(
           id: UUID().uuidString,
           senderId: user.uid,
           senderName: DataManager.shared.userName,
           text: "Sent an image", // Fallback text
           timestamp: Date(),
           imageUrl: imageString // Save the image data string
       )
       
       try? db.collection("plans").document(planId).collection("messages").addDocument(from: msg)
   }
    
    // BLOCK USER
   func blockUser(uidToBlock: String) {
       guard let myUid = Auth.auth().currentUser?.uid else { return }
       
       db.collection("users").document(myUid).updateData([
           "blockedUsers": FieldValue.arrayUnion([uidToBlock])
       ]) { _ in
           self.blockedUserIds.append(uidToBlock) // Update local immediately
       }
   }
    // 2. REPORT CONTENT
    func reportContent(id: String, type: String, reason: String) {
        let reportData: [String: Any] = [
            "contentId": id,
            "type": type, // "message" or "plan"
            "reason": reason,
            "reporterId": Auth.auth().currentUser?.uid ?? "anon",
            "timestamp": Date()
        ]
        db.collection("reports").addDocument(data: reportData)
    }
    
    // 3. LISTEN FOR BLOCKED USERS
    func listenForBlockedUsers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).addSnapshotListener { doc, _ in
            if let data = doc?.data(), let blocked = data["blockedUsers"] as? [String] {
                self.blockedUserIds = blocked
            }
        }
    }
    // FETCH ANY USER (Not just self)
    func fetchAnyUserProfile(uid: String, completion: @escaping ([String: Any]) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                completion(data)
            } else {
                completion(["name": "Unknown User", "bio": "No Bio"])
            }
        }
    }
}
