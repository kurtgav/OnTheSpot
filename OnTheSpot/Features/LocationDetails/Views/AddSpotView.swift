import SwiftUI
import MapKit

struct AddSpotView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Logic
    @StateObject private var searchService = PlaceSearchService()
    var onSave: (Location) -> Void
    
    // State
    @State private var selectedMapItem: MKMapItem?
    @State private var selectedCategory = "Study Spot"
    @State private var customName = ""
    
    let categories = [
            "Study Spot", "Coffee Shop", "Coworking Space", "Library",
            "Hotel Lobby", "Club", "Open Public Space", "Bookstore", "Wifi Cafe", "Late Night Spot", "Quiet Zone", "Social Hub", "Food Court", "Outdoor Park"
        ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. SEARCH BAR
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Place")
                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("e.g. Jollibee, Starbucks...", text: $searchService.query)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    // 2. SEARCH RESULTS LIST
                    if selectedMapItem == nil {
                        List(searchService.searchResults, id: \.self) { item in
                            Button(action: {
                                withAnimation {
                                    selectedMapItem = item
                                    customName = item.name ?? ""
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown").font(.headline)
                                    Text(item.placemark.title ?? "").font(.caption).foregroundColor(.gray)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    // 3. CONFIRMATION FORM (Shows only after selection)
                    else if let item = selectedMapItem {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Map Preview
                                MapPreview(coordinate: item.placemark.coordinate)
                                    .frame(height: 150)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primaryAccent, lineWidth: 2)
                                    )
                                    .overlay(
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.primaryAccent)
                                            .offset(y: -10)
                                    )
                                
                                // Selected Place Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SELECTED LOCATION")
                                        .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                    Text(customName)
                                        .font(.title2).fontWeight(.bold)
                                    Text(item.placemark.title ?? "Unknown Address")
                                        .font(.subheadline).foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                
                                // Category Picker
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("CATEGORY").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(categories, id: \.self) { cat in
                                                Button(action: { selectedCategory = cat }) {
                                                    Text(cat)
                                                        .font(.caption).fontWeight(.bold)
                                                        .padding(.horizontal, 16).padding(.vertical, 10)
                                                        .background(selectedCategory == cat ? Color.primaryAccent : Color.gray.opacity(0.1))
                                                        .foregroundColor(selectedCategory == cat ? .black : .primary)
                                                        .cornerRadius(20)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Buttons
                                HStack(spacing: 15) {
                                    Button(action: {
                                        withAnimation { selectedMapItem = nil } // Back to search
                                    }) {
                                        Text("Change").fontWeight(.bold).foregroundColor(.gray)
                                            .frame(maxWidth: .infinity).padding()
                                            .background(Color.gray.opacity(0.1)).cornerRadius(16)
                                    }
                                    
                                    Button(action: saveLocation) {
                                        Text("Add Spot").fontWeight(.bold).foregroundColor(.black)
                                            .frame(maxWidth: .infinity).padding()
                                            .background(Color.primaryAccent).cornerRadius(16)
                                    }
                                }
                                .padding(.top, 20)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Add New Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
    
    func saveLocation() {
        guard let item = selectedMapItem else { return }
        
        let newLocation = Location(
            name: customName,
            category: selectedCategory,
            coordinate: item.placemark.coordinate,
            currentStatus: .available, // Default status
            lastUpdate: Date()
        )
        
        onSave(newLocation)
        presentationMode.wrappedValue.dismiss()
    }
}

// Helper: Static Map Preview
struct MapPreview: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        return map
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
