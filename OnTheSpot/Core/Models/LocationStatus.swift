import SwiftUI

enum LocationStatus {
    // These are the cases the error says are missing. We define them here.
    case quiet
    case justRight
    case noisy
    case noLine
    case shortLine
    case longLine
    case available
    case inUse
    
    // The clean title for the UI
    var title: String {
        switch self {
        case .quiet: return "Quiet"
        case .justRight: return "Moderate"
        case .noisy: return "Busy"
        case .noLine: return "No Queue"
        case .shortLine: return "Short Wait"
        case .longLine: return "Long Wait"
        case .available: return "Available"
        case .inUse: return "Occupied"
        }
    }
    
    // The SF Symbol icon name
    var iconName: String {
        switch self {
        case .quiet: return "waveform.path.ecg"
        case .justRight: return "person.2.fill"
        case .noisy: return "speaker.wave.3.fill"
        case .noLine: return "figure.walk"
        case .shortLine: return "hourglass"
        case .longLine: return "person.3.sequence.fill"
        case .available: return "checkmark.circle.fill"
        case .inUse: return "xmark.circle.fill"
        }
    }
    
    // The Matcha Theme Color
    var color: Color {
        switch self {
        case .quiet, .noLine, .available:
            return .primaryAccent // Matcha
        case .justRight, .shortLine:
            return Color.yellow.opacity(0.8)
        case .noisy, .longLine, .inUse:
            return Color.red.opacity(0.8)
        }
    }
}
