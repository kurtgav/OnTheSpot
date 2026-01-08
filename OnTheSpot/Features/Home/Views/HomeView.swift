import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddSheet = false // State for the Add Sheet
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- REAL TIME MAP ---
                    ZStack(alignment: .bottomTrailing) {
                        Map(
                            coordinateRegion: $viewModel.region,
                            showsUserLocation: true,
                            annotationItems: viewModel.locations
                        ) { location in
                            MapAnnotation(coordinate: location.coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .resizable()
                                    .foregroundColor(location.currentStatus.color)
                                    .frame(width: 30, height: 30)
                                    .background(Circle().fill(.white))
                                    .shadow(radius: 4)
                            }
                        }
                        .frame(height: 350)
                        
                        // "My Location" Button (Small)
                        Button(action: {
                            if let userLoc = viewModel.currentUserLocation {
                                withAnimation {
                                    viewModel.region.center = userLoc
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding(12)
                                .background(Color.appBackground)
                                .foregroundColor(.primaryAccent)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                    .mask(LinearGradient(colors: [.black, .black, .black, .clear], startPoint: .top, endPoint: .bottom))
                    .ignoresSafeArea()
                    
                    // --- LIVE FEED LIST ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Nearby Spots")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                HStack(spacing: 4) {
                                    Circle().fill(Color.red).frame(width: 8, height: 8)
                                    Text("LIVE").font(.caption).fontWeight(.bold).foregroundColor(.secondaryText)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
                            ForEach($viewModel.locations) { $location in
                                NavigationLink(destination: LocationDetailView(location: $location)) {
                                    StatusCardView(location: location)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, -50)
                        .padding(.bottom, 80) // Extra padding for the FAB
                    }
                }
                
                // --- FLOATING "ADD SPOT" BUTTON ---
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(Color.primaryAccent)
                                .clipShape(Circle())
                                .shadow(color: Color.primaryAccent.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
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
}
