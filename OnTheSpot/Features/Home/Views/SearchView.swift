import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. New Glow Background
                AtmosphereBackground(color: .purple)
                
                VStack(spacing: 0) {
                    // --- HEADER ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Discover")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.6))
                            TextField("Search...", text: $viewModel.searchText)
                                .accentColor(.primaryAccent)
                            if viewModel.isFiltering {
                                Button(action: { withAnimation { viewModel.clearAll() } }) {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            
                            // A. SEARCH RESULTS
                            if viewModel.isFiltering {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        if let cat = viewModel.selectedCategory { FilterBadge(text: cat) { withAnimation { viewModel.selectedCategory = nil }}}
                                        if let vibe = viewModel.selectedVibe { FilterBadge(text: vibe) { withAnimation { viewModel.selectedVibe = nil }}}
                                    }
                                    .padding(.horizontal)
                                }
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredLocations) { location in
                                        if let binding = dataManager.binding(for: location.id) {
                                            NavigationLink(destination: LocationDetailView(location: binding)) {
                                                StatusCardView(location: location)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // B. MAGAZINE DISCOVERY
                            else {
                                // 1. FEATURED (Large Cards)
                                VStack(alignment: .leading) {
                                    Text("Trending Now")
                                        .font(.title3).fontWeight(.bold).foregroundColor(.white).padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(viewModel.trendingLocations) { location in
                                                if let binding = dataManager.binding(for: location.id) {
                                                    NavigationLink(destination: LocationDetailView(location: binding)) {
                                                        BigFeaturedCard(location: location)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // 2. CATEGORIES
                                VStack(alignment: .leading) {
                                    Text("Categories").font(.headline).foregroundColor(.white.opacity(0.7)).padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.categories, id: \.self) { category in
                                                Button(action: { withAnimation { viewModel.toggleCategory(category) } }) {
                                                    Text(category)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 20)
                                                        .padding(.vertical, 10)
                                                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // 3. VIBE CHECK
                                VStack(alignment: .leading) {
                                    Text("Vibe Check").font(.title3).fontWeight(.bold).foregroundColor(.white).padding(.horizontal)
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                        ForEach(viewModel.vibes, id: \.title) { vibe in
                                            ColorfulVibeCard(vibe: vibe) {
                                                withAnimation { viewModel.toggleVibe(vibe.title) }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// --- HELPER FUNCTION FOR FIXED IMAGES ---
func getFixedImage(for locationName: String) -> String {
    if locationName.contains("Library") { return "trend1" }
    if locationName.contains("Jollibee") { return "trend2" }
    if locationName.contains("Canteen") { return "trend3" }
    // Fallback for others to prevent crashes, reusing them consistently
    if locationName.contains("Parking") { return "trend1" }
    return "trend2" // Default
}

// MARK: - Components

struct BigFeaturedCard: View {
    let location: Location
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // FIXED IMAGE
            Image(getFixedImage(for: location.name))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 260, height: 350)
                .clipped()
            
            // Gradient Overlay
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(location.currentStatus.title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .padding(6)
                    .background(location.currentStatus.color)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                
                Text(location.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(location.category)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
        }
        .frame(width: 260, height: 350)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct ColorfulVibeCard: View {
    let vibe: VibeOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: vibe.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    Text(vibe.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(20)
            .background(
                LinearGradient(colors: [vibe.color.opacity(0.8), vibe.color.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
        }
    }
}

struct FilterBadge: View {
    let text: String
    let onRemove: () -> Void
    var body: some View {
        HStack(spacing: 6) {
            Text(text).font(.caption).fontWeight(.bold)
            Button(action: onRemove) { Image(systemName: "xmark").font(.caption2) }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.primaryAccent).foregroundColor(.black).cornerRadius(20)
    }
}
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
