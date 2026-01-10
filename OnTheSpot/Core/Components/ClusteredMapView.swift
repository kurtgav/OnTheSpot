import SwiftUI
import MapKit

struct ClusteredMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var locations: [Location]
    var onMapTap: () -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        
        // Diff Logic: Only update if count changed to prevent flicker
        if uiView.annotations.count != locations.count + 1 { // +1 for user location
            uiView.removeAnnotations(uiView.annotations)
            let newAnnotations = locations.map { loc -> LocationAnnotation in
                let ann = LocationAnnotation(location: loc)
                ann.coordinate = loc.coordinate
                return ann
            }
            uiView.addAnnotations(newAnnotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        
        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                // Zoom in on cluster
                mapView.showAnnotations(cluster.memberAnnotations, animated: true)
            } else if let spot = view.annotation as? LocationAnnotation {
                // Handle Tap (Open Sheet logic would go here if we link it back)
                // For now, we rely on the list interaction
            }
        }
    }
}

// 1. The Pin Data Object
class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var location: Location
    
    init(location: Location) {
        self.location = location
        self.coordinate = location.coordinate
    }
}

// 2. The Custom Pin View (UI)
class LocationAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "spotCluster" // Groups them together
            if let spot = annotation as? LocationAnnotation {
                markerTintColor = UIColor(spot.location.currentStatus.color)
                glyphImage = UIImage(systemName: spot.location.currentStatus.iconName)
                displayPriority = .required
            }
        }
    }
}

// 3. The Cluster View (The Bubble)
class ClusterAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            markerTintColor = .black // Dark Cluster
            glyphText = "\( (annotation as? MKClusterAnnotation)?.memberAnnotations.count ?? 0 )"
            displayPriority = .required
        }
    }
}
