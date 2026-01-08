import SwiftUI
import MapKit
import CoreLocation
import Combine

class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @Published var locations: [Location] = []
    @Published var currentUserLocation: CLLocationCoordinate2D?
    
    @Published var selectedCategory: String? = nil
    
    let categories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking"]
    
    var filteredLocations: [Location] {
        guard let category = selectedCategory else {
            return locations
        }
        return locations.filter { $0.category == category }
    }
    
    func toggleCategory(_ category: String) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        DataManager.shared.$locations
            .assign(to: \.locations, on: self)
            .store(in: &cancellables)
            
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print("Location Permission missing")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentUserLocation = location.coordinate
    }
    
    func addNewSpot(name: String, category: String) {
        let coord = currentUserLocation ?? region.center
        let newLocation = Location(
            name: name,
            category: category,
            coordinate: coord,
            currentStatus: .available,
            lastUpdate: Date()
        )
        DataManager.shared.addLocation(newLocation)
    }
}
