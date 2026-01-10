import SwiftUI
import FirebaseAuth

struct CreatePlanView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Passed Data
    let locationId: String
    let locationName: String
    
    // Form State
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // Default +1 hr
    @State private var maxGuests = 4
    @State private var allowInvites = true
    @State private var selectedTag = "Social"
    
    let tags = ["Study", "Social", "Gym", "Errand", "Work", "Chill", "Food"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                Form {
                    // 1. BASICS
                    Section(header: Text("THE PLAN")) {
                        TextField("Title (e.g. Finals Prep)", text: $title)
                        
                        Picker("Vibe Tag", selection: $selectedTag) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag).tag(tag)
                            }
                        }
                    }
                    
                    // 2. TIME WINDOW
                    Section(header: Text("WHEN")) {
                        DatePicker("Starts", selection: $startTime, in: Date()...)
                        DatePicker("Ends", selection: $endTime, in: startTime...)
                    }
                    
                    // 3. SETTINGS
                    Section(header: Text("SETTINGS")) {
                        Stepper("Max People: \(maxGuests)", value: $maxGuests, in: 2...20)
                        Toggle("Allow Guests to Invite?", isOn: $allowInvites)
                    }
                    
                    // 4. PREVIEW
                    Section(footer: Text("Host: \(DataManager.shared.userName) • Location: \(locationName)")) {
                        EmptyView()
                    }
                }
                .scrollContentBackground(.hidden) // Makes form blend with background
            }
            .navigationTitle("Host Hangout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createPlan() }
                        .fontWeight(.bold)
                        .disabled(title.isEmpty)
                }
            }
        }
    }
    
    func createPlan() {
        let hostName = DataManager.shared.userName.isEmpty ? "Unknown" : DataManager.shared.userName
        let hostId = Auth.auth().currentUser?.uid ?? "TEST_USER"
        
        let newPlan = Plan(
            id: UUID().uuidString,
            hostId: hostId,
            hostName: hostName,
            locationId: locationId,
            locationName: locationName,
            title: title,
            startTime: startTime,
            endTime: endTime,
            maxParticipants: maxGuests,
            allowInvites: allowInvites,
            tag: selectedTag,
            participants: [hostId]
        )
        
        CloudDataManager.shared.createPlan(newPlan)
        presentationMode.wrappedValue.dismiss()
    }
}
