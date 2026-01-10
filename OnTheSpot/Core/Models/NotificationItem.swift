import Foundation

struct NotificationItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let timestamp: Date
    let iconName: String
    var isRead: Bool
    
    init(id: UUID = UUID(), title: String, message: String, timestamp: Date, iconName: String, isRead: Bool = false) {
        self.id = id
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.iconName = iconName
        self.isRead = isRead
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
