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
    
    // Filtering Logic
    var filteredLocations: [Location] {
        guard let category = selectedCategory else {
            return locations
        }
        return locations.filter { $0.category == category }
    }
    
    func toggleCategory(_ category: String) {
        selectedCategory = (selectedCategory == category) ? nil : category
    }
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        // 🔥 CRITICAL FIX: LISTEN TO CLOUD DATA MANAGER
        // This connects the view model to the live internet database
        CloudDataManager.shared.$locations
            .receive(on: DispatchQueue.main) // Ensure updates happen on UI thread
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
    
    // We don't need addNewSpot logic here anymore because HomeView calls CloudDataManager directly
}
