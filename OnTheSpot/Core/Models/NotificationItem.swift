import Foundation

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timestamp: Date
    let iconName: String
    var isRead: Bool = false
    
    // Helper for display time
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
