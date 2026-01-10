import SwiftUI
import Combine
import FirebaseAuth // 👈 Crucial Import

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    // --- 1. SETTINGS ---
    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    
    // --- 2. USER PROFILE ---
    @Published var userName: String = "User"
    @Published var userBio: String = "Rookie"
    @Published var userLocation: String = "Unknown"
    @Published var profileImage: UIImage? = nil
    @Published var userTags: [String] = []
    
    // --- 3. STATS ---
    @Published var contributionPoints: Int = 0
    @Published var spotsAdded: Int = 0
    
    // --- 4. APP DATA ---
    @Published var notifications: [NotificationItem] = []
    
    var userLevel: String {
        if contributionPoints > 500 { return "Campus Legend" }
        if contributionPoints > 200 { return "Pro Spotter" }
        return "Rookie"
    }
    
    var progressToNextLevel: Double {
        let remainder = Double(contributionPoints % 200)
        return remainder / 200.0
    }
    
    private init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        
        // Try loading image if user is already logged in
        if Auth.auth().currentUser != nil {
            loadProfileImage()
        }
    }
    
    // --- FIXED IMAGE LOGIC (Unique per User) ---
    func saveProfileImage(_ image: UIImage) {
        self.profileImage = image
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DispatchQueue.global().async {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = self.getDocumentsDirectory().appendingPathComponent("profile_\(uid).jpg")
                try? data.write(to: filename)
            }
        }
    }
    
    func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.profileImage = nil
            return
        }
        
        let filename = getDocumentsDirectory().appendingPathComponent("profile_\(uid).jpg")
        
        if let data = try? Data(contentsOf: filename) {
            DispatchQueue.main.async {
                self.profileImage = UIImage(data: data)
            }
        } else {
            DispatchQueue.main.async {
                self.profileImage = nil // Reset if no file
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // --- NOTIFICATIONS ---
    func triggerNotification(for location: Location) {
        let newItem = NotificationItem(
            title: "Update: \(location.name)",
            message: "is now \(location.currentStatus.title)",
            timestamp: Date(),
            iconName: location.currentStatus.iconName
        )
        withAnimation { notifications.insert(newItem, at: 0) }
        NotificationManager.shared.sendNotification(title: "Spot Update", body: newItem.message)
    }
    
    func clearNotifications() {
        withAnimation { notifications.removeAll() }
    }
    
    // --- LOGOUT ---
    func logOut() {
        try? Auth.auth().signOut()
        self.profileImage = nil
        self.userName = "User"
        self.userBio = "Rookie"
        self.contributionPoints = 0
    }
}
