import Foundation

struct Plan: Identifiable, Codable {
    var id: String?
    
    // Host Info
    let hostId: String
    let hostName: String
    
    // Location Info
    let locationId: String
    let locationName: String
    
    // Details
    let title: String
    let startTime: Date
    let endTime: Date // New: Time Window
    
    // Settings
    let maxParticipants: Int
    let allowInvites: Bool // New: "Can others invite?"
    let tag: String // New: "Study", "Social", etc.
    
    // Participants
    var participants: [String] // List of User IDs
}
