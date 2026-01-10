import Foundation
import FirebaseAuth

struct ChatMessage: Identifiable, Codable {
    var id: String?
    let senderId: String
    let senderName: String
    let text: String
    let timestamp: Date
    var imageUrl: String? = nil
    
    var isMe: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
}
