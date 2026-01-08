import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    // --- 1. THEME SETTINGS ---
    @Published var isDarkMode: Bool = true
    
    // --- 2. USER PROFILE ---
    @Published var userName: String = "Kurt Gavin"
    @Published var userBio: String = "Rookie Spotter | Coffee Enthusiast"
    @Published var userLocation: String = "Quezon City, PH"
    
    // --- 3. APP DATA ---
    @Published var locations: [Location] = Location.mockData
    @Published var notifications: [NotificationItem] = []
    
    // --- 4. STATS (Gamification) ---
    @Published var contributionPoints: Int = 120
    @Published var spotsAdded: Int = 5
    
    // 👇 THIS IS WHAT WAS MISSING 👇
    var userLevel: String {
        if contributionPoints > 500 { return "Campus Legend" }
        if contributionPoints > 200 { return "Pro Spotter" }
        return "Rookie"
    }
    
    var progressToNextLevel: Double {
        // Level up every 200 points
        let remainder = Double(contributionPoints % 200)
        return remainder / 200.0
    }
    // 👆 END MISSING PART 👆
    
    private init() {
        // Inject Dummy Notification for testing
        notifications = [
            NotificationItem(title: "Welcome", message: "Start spotting!", timestamp: Date(), iconName: "star.fill")
        ]
    }
    
    // --- LOGIC ---
    func addLocation(_ location: Location) {
        locations.append(location)
        addPointsForNewSpot()
    }
    
    func binding(for id: UUID) -> Binding<Location>? {
        guard let index = locations.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.locations[index] },
            set: { self.locations[index] = $0 }
        )
    }
    
    func triggerNotification(for location: Location) {
        let newItem = NotificationItem(
            title: "Status Update: \(location.name)",
            message: "is now marked as \(location.currentStatus.title.uppercased())",
            timestamp: Date(),
            iconName: location.currentStatus.iconName
        )
        withAnimation { notifications.insert(newItem, at: 0) }
    }
    
    func clearNotifications() {
        withAnimation { notifications.removeAll() }
    }
    
    func addPointsForNewSpot() { contributionPoints += 50; spotsAdded += 1 }
    func addPointsForUpdate() { contributionPoints += 10 }
}
