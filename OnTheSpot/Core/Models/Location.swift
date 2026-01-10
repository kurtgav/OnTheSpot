import Foundation
import CoreLocation
import SwiftUI
// REMOVED 'FirebaseFirestoreSwift' - Not needed!

struct Location: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    
    // Database Storage (Double)
    var latitude: Double
    var longitude: Double
    
    var currentStatus: LocationStatus
    var lastUpdate: Date
    
    // Helper for App (CLLocationCoordinate2D)
    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set { latitude = newValue.latitude; longitude = newValue.longitude }
    }
    
    init(id: UUID = UUID(), name: String, category: String, coordinate: CLLocationCoordinate2D, currentStatus: LocationStatus, lastUpdate: Date) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.currentStatus = currentStatus
        self.lastUpdate = lastUpdate
    }
    
    // Explicit Mock Data
    static let mockData: [Location] = [
        Location(
            name: "Main Library - 3rd Floor",
            category: "Study Spot",
            coordinate: CLLocationCoordinate2D(latitude: 14.6549, longitude: 121.0645),
            currentStatus: .quiet,
            lastUpdate: Date()
        ),
        Location(
            name: "Jollibee - Campus Ave",
            category: "Fast Food",
            coordinate: CLLocationCoordinate2D(latitude: 14.6555, longitude: 121.0650),
            currentStatus: .longLine,
            lastUpdate: Date()
        ),
        Location(
            name: "Student Canteen",
            category: "Canteen",
            coordinate: CLLocationCoordinate2D(latitude: 14.6540, longitude: 121.0635),
            currentStatus: .shortLine,
            lastUpdate: Date()
        ),
        Location(
            name: "Bus Terminal - Lane A",
            category: "Terminal",
            coordinate: CLLocationCoordinate2D(latitude: 14.6520, longitude: 121.0610),
            currentStatus: .moderate,
            lastUpdate: Date()
        ),
        Location(
            name: "Main Parking Lot",
            category: "Parking",
            coordinate: CLLocationCoordinate2D(latitude: 14.6510, longitude: 121.0660),
            currentStatus: .available,
            lastUpdate: Date()
        )
    ]
}
