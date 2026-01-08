import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var dataManager = DataManager.shared
    @State private var showAddSheet = false
    
    // Sheet State
    @State private var sheetOffset: CGFloat = 0
    @State private var isSheetOpen: Bool = true
    
    // Constants
    let openHeight: CGFloat = 400
    let hiddenOffset: CGFloat = 450
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 1. Map Layer (Background)
                HomeMapLayer(
                    region: $viewModel.region,
                    locations: viewModel.filteredLocations,
                    onMapTap: closeSheet
                )
                
                // 2. The Unified Floating Header (Top)
                HomeHeaderLayer(
                    categories: viewModel.categories,
                    selectedCategory: viewModel.selectedCategory,
                    onToggle: viewModel.toggleCategory,
                    isSheetOpen: isSheetOpen
                )
                
                // 3. Right-Side Control Stack (Location + FAB)
                // We group these together for better ergonomics
                ControlStackLayer(
                    isSheetOpen: isSheetOpen,
                    onLocationTap: {
                        if let userLoc = viewModel.currentUserLocation {
                            withAnimation { viewModel.region.center = userLoc }
                        } else {
                            viewModel.checkLocationAuthorization()
                        }
                    },
                    onAddTap: { showAddSheet = true }
                )
                
                // 4. Show List Button (Bottom Center)
                if !isSheetOpen {
                    HomeShowListButton(onTap: openSheet)
                }
                
                // 5. Bottom Sheet (Draggable Drawer)
                HomeBottomSheet(
                    isOpen: $isSheetOpen,
                    offset: $sheetOffset,
                    categoryTitle: viewModel.selectedCategory,
                    locations: viewModel.filteredLocations,
                    dataManager: dataManager
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet) {
                AddSpotView { name, category in
                    viewModel.addNewSpot(name: name, category: category)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Helper functions
    func closeSheet() {
        withAnimation(.spring()) {
            isSheetOpen = false
            sheetOffset = hiddenOffset
        }
    }
    
    func openSheet() {
        withAnimation(.spring()) {
            isSheetOpen = true
            sheetOffset = 0
        }
    }
}

// MARK: - 1. Map Struct (Upgraded Pins)
struct HomeMapLayer: View {
    @Binding var region: MKCoordinateRegion
    var locations: [Location]
    var onMapTap: () -> Void
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: locations
        ) { location in
            MapAnnotation(coordinate: location.coordinate) {
                // 3D Pin Style
                ZStack {
                    Circle()
                        .fill(location.currentStatus.color.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 26, height: 26)
                        .shadow(radius: 2)
                    
                    Image(systemName: location.currentStatus.iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(location.currentStatus.color)
                        .frame(width: 14, height: 14)
                }
                .offset(y: -10) // Lift pin slightly above coordinate
            }
        }
        .ignoresSafeArea()
        .onTapGesture { onMapTap() }
    }
}

// MARK: - 2. Header Struct (Unified "Floating Island")
struct HomeHeaderLayer: View {
    var categories: [String]
    var selectedCategory: String?
    var onToggle: (String) -> Void
    var isSheetOpen: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                // Top Row: Greeting + Live Badge
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ON THE SPOT")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2)
                            .foregroundColor(.secondaryText)
                        Text("Find your vibe.")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Live Pulse Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("LIVE MAP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                
                // Bottom Row: Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: { withAnimation { onToggle(category) } }) {
                                Text(category)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedCategory == category ? .black : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ? Color.primaryAccent : Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            .padding(20)
            // GLASS EFFECT
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 16)
            .padding(.top, 10) // Safe Area padding
            
            Spacer()
        }
        // Hide header when sheet is up to reduce clutter? (Optional, kept visible for now)
        .opacity(isSheetOpen ? 1.0 : 1.0)
    }
}

// MARK: - 3. Control Stack (Location + FAB)
struct ControlStackLayer: View {
    var isSheetOpen: Bool
    var onLocationTap: () -> Void
    var onAddTap: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    // Location Button
                    Button(action: onLocationTap) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primaryAccent)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    // Add Button (FAB)
                    Button(action: onAddTap) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(Color.primaryAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.primaryAccent.opacity(0.4), radius: 10, y: 5)
                    }
                }
                .padding(.trailing, 20)
                // Move up when sheet is open so it doesn't get covered
                .padding(.bottom, isSheetOpen ? 420 : 40)
                .animation(.spring(), value: isSheetOpen)
            }
        }
    }
}

// MARK: - 4. Show List Button
struct HomeShowListButton: View {
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                    Text("List View")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.primaryAccent)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - 5. Bottom Sheet (Tight Layout)
struct HomeBottomSheet: View {
    @Binding var isOpen: Bool
    @Binding var offset: CGFloat
    var categoryTitle: String?
    var locations: [Location]
    var dataManager: DataManager
    
    // Constants
    let sheetHeight: CGFloat = 350
    let peekOffset: CGFloat = 520
    
    var body: some View {
        VStack {
            Spacer()
            
            // MAIN BLACK FRAME
            VStack(spacing: 0) {
                
                // 1. Unified Header (Handle + Title)
                VStack(spacing: 12) {
                    // Drag Capsule
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                    
                    // Title (Moved Up)
                    Text(categoryTitle ?? "Nearby Spots")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 15) // Small gap before list starts
                // Make the whole header draggable
                .background(Color.appBackground)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let drag = value.translation.height
                            if drag > 0 { offset = drag }
                        }
                        .onEnded { value in
                            if value.translation.height > 80 {
                                withAnimation(.spring()) { isOpen = false; offset = peekOffset }
                            } else {
                                withAnimation(.spring()) { isOpen = true; offset = 0 }
                            }
                        }
                )
                
                // 2. Content List (Fills the rest)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(locations) { location in
                            if let binding = dataManager.binding(for: location.id) {
                                NavigationLink(destination: LocationDetailView(location: binding)) {
                                    StatusCardView(location: location)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
                .background(Color.appBackground)
            }
            .background(Color.appBackground) // The whole frame is black
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: -5)
            .frame(height: sheetHeight)
            .offset(y: isOpen ? offset : peekOffset)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}


// Helpers
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
