import SwiftUI
import Combine
import MapKit
import CoreLocation

class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @Published var locations: [Location] = Location.mockData
    @Published var currentUserLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
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
        
        // 1. Save your real location
        self.currentUserLocation = location.coordinate
        
        // 2. AUTO-FOLLOW: Snap the camera to your location instantly
        withAnimation {
             self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }

    
    func addNewSpot(name: String, category: String) {
        // If we don't have a GPS signal, use the center of the screen
        let coord = currentUserLocation ?? region.center
        
        let newLocation = Location(
            name: name,
            category: category,
            coordinate: coord,
            currentStatus: .available,
            lastUpdate: Date()
        )
        
        withAnimation {
            self.locations.append(newLocation)
        }
    }
}

