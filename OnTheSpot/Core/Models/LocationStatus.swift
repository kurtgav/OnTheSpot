import SwiftUI

// Added String (Raw Value) and Codable
enum LocationStatus: String, Codable {
    case quiet, justRight, noisy
    case noLine, shortLine, longLine
    case available, inUse
    
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
    
    var color: Color {
        switch self {
        case .quiet, .noLine, .available: return .primaryAccent
        case .justRight, .shortLine: return .yellow
        case .noisy, .longLine, .inUse: return .red
        }
    }
}

// Helpers
extension LocationStatus {
    static var moderate: LocationStatus { .shortLine }
    static var occupied: LocationStatus { .inUse }
}
