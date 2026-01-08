import Foundation
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    var name: String            // Changed to VAR
    var category: String        // Changed to VAR
    let coordinate: CLLocationCoordinate2D
    var currentStatus: LocationStatus
    var lastUpdate: Date
    
    static let mockData: [Location] = [
        .init(name: "Main Library - 3rd Floor", category: "Study Spot", coordinate: .init(latitude: 14.6549, longitude: 121.0645), currentStatus: .quiet, lastUpdate: Date()),
        .init(name: "Jollibee - Campus Ave", category: "Fast Food", coordinate: .init(latitude: 14.6555, longitude: 121.0650), currentStatus: .longLine, lastUpdate: Date()),
        .init(name: "Student Canteen", category: "Canteen", coordinate: .init(latitude: 14.6540, longitude: 121.0635), currentStatus: .shortLine, lastUpdate: Date()),
        .init(name: "Bus Terminal - Lane A", category: "Terminal", coordinate: .init(latitude: 14.6520, longitude: 121.0610), currentStatus: .moderate, lastUpdate: Date()),
        .init(name: "Main Parking Lot", category: "Parking", coordinate: .init(latitude: 14.6510, longitude: 121.0660), currentStatus: .available, lastUpdate: Date()),
        .init(name: "Science Complex Gym", category: "Facility", coordinate: .init(latitude: 14.6560, longitude: 121.0670), currentStatus: .occupied, lastUpdate: Date())
    ]
}

extension LocationStatus {
    static var moderate: LocationStatus { .shortLine }
    static var occupied: LocationStatus { .inUse }
}
