import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject var cloudManager = CloudDataManager.shared
    
    @State private var recentSearches = ["Jollibee", "Library", "Parking"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemBackground).ignoresSafeArea()
                AtmosphereBackground(color: .purple).opacity(0.3)
                
                VStack(spacing: 0) {
                    // HEADER
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Discover")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Search...", text: $viewModel.searchText)
                                .accentColor(.primaryAccent)
                                .foregroundColor(.primary)
                            if viewModel.isFiltering {
                                Button(action: { withAnimation { viewModel.clearAll() } }) {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
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
                                        if let cat = viewModel.selectedCategory {
                                            FilterBadge(text: cat) { withAnimation { viewModel.selectedCategory = nil }}
                                        }
                                        if let vibe = viewModel.selectedVibe {
                                            FilterBadge(text: vibe) { withAnimation { viewModel.selectedVibe = nil }}
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredLocations) { location in
                                        if let binding = cloudManager.binding(for: location.id) {
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
                                // 1. CATEGORIES
                                VStack(alignment: .leading) {
                                    Text("Categories").font(.headline).foregroundColor(.gray).padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.categories, id: \.self) { category in
                                                Button(action: { withAnimation { viewModel.toggleCategory(category) } }) {
                                                    Text(category)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 20).padding(.vertical, 10)
                                                        .background(Color.gray.opacity(0.3)).cornerRadius(20)
                                                        .overlay(Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // 2. RECENT SEARCHES
                                if !recentSearches.isEmpty && viewModel.searchText.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Recent").font(.caption).fontWeight(.bold).foregroundColor(.gray).padding(.horizontal)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(recentSearches, id: \.self) { term in
                                                    Button(action: { viewModel.searchText = term }) {
                                                        Text(term)
                                                            .font(.subheadline)
                                                            .padding(.horizontal, 16).padding(.vertical, 8)
                                                            .background(Color(UIColor.secondarySystemBackground))
                                                            .cornerRadius(20)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // 3. TRENDING NOW
                                VStack(alignment: .leading) {
                                    Text("Trending Now").font(.title3).fontWeight(.bold).foregroundColor(.primary).padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(viewModel.trendingLocations) { location in
                                                if let binding = cloudManager.binding(for: location.id) {
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
                                
                                // 4. VIBE CHECK
                                VStack(alignment: .leading) {
                                    Text("Vibe Check").font(.title3).fontWeight(.bold).foregroundColor(.primary).padding(.horizontal)
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

// MARK: - SUBCOMPONENTS (These fix the "Cannot find" errors)

struct BigFeaturedCard: View {
    let location: Location
    
    // Helper to get image based on name (so it's consistent)
    var image: String {
        if location.name.contains("Jollibee") { return "trend2" }
        if location.name.contains("Library") { return "trend1" }
        return "trend3" // Default
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(image) // Using Asset Catalog Images
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 260, height: 350)
                .clipped()
            
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
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
                    Image(systemName: vibe.icon).font(.title2).foregroundColor(.white).padding(.bottom, 8)
                    Text(vibe.title).font(.headline).fontWeight(.bold).foregroundColor(.white)
                }
                Spacer()
            }
            .padding(20)
            .background(LinearGradient(colors: [vibe.color.opacity(0.8), vibe.color.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
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
