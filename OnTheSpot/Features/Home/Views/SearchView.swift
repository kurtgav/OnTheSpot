import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    // Mock Recent Searches
    @State private var recentSearches = ["Jollibee", "Library", "Parking"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- 1. HEADER & SEARCH BAR ---
                    VStack(spacing: 15) {
                        Text("Discover")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondaryText)
                            
                            TextField("Search spots, food, parking...", text: $viewModel.searchText)
                                .foregroundColor(.white)
                                .accentColor(.primaryAccent)
                            
                            // CLEAR BUTTON (Visible if filtering)
                            if viewModel.isFiltering {
                                Button(action: {
                                    withAnimation { viewModel.clearAll() }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondaryText)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    .background(Color.appBackground) // Sticky Header feel
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // === STATE 1: SHOWING RESULTS ===
                            if viewModel.isFiltering {
                                // Active Filters Display
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        if let cat = viewModel.selectedCategory {
                                            FilterBadge(text: cat) { viewModel.selectedCategory = nil }
                                        }
                                        if let vibe = viewModel.selectedVibe {
                                            FilterBadge(text: vibe) { viewModel.selectedVibe = nil }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                if viewModel.filteredLocations.isEmpty {
                                    // EMPTY STATE
                                    VStack(spacing: 20) {
                                        Spacer().frame(height: 50)
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 60))
                                            .foregroundColor(.white.opacity(0.2))
                                        Text("No spots found matching that.")
                                            .foregroundColor(.secondaryText)
                                        Button("Clear Filters") {
                                            withAnimation { viewModel.clearAll() }
                                        }
                                        .foregroundColor(.primaryAccent)
                                    }
                                } else {
                                    // RESULT LIST
                                    LazyVStack(spacing: 12) {
                                        ForEach(viewModel.filteredLocations) { location in
                                            NavigationLink(destination: LocationDetailView(location: .constant(location))) {
                                                StatusCardView(location: location)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // === STATE 2: DISCOVERY MODE (Default) ===
                            else {
                                // A. RECENT SEARCHES
                                if !recentSearches.isEmpty && viewModel.searchText.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Recent").font(.caption).fontWeight(.bold).foregroundColor(.secondaryText).padding(.horizontal)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(recentSearches, id: \.self) { term in
                                                    Button(action: { viewModel.searchText = term }) {
                                                        Text(term)
                                                            .font(.subheadline)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 8)
                                                            .background(Color.white.opacity(0.05))
                                                            .cornerRadius(20)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // B. CATEGORIES
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Categories").font(.title3).fontWeight(.bold).foregroundColor(.white).padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(viewModel.categories, id: \.self) { category in
                                                Button(action: {
                                                    withAnimation { viewModel.selectedCategory = category }
                                                }) {
                                                    Text(category)
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 10)
                                                        .background(Color.white.opacity(0.1))
                                                        .cornerRadius(20)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // C. TRENDING
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "flame.fill").foregroundColor(.orange)
                                        Text("Trending Now").font(.title3).fontWeight(.bold).foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(viewModel.trendingLocations) { location in
                                                NavigationLink(destination: LocationDetailView(location: .constant(location))) {
                                                    TrendingCard(location: location)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // D. VIBE CHECK (Now Functional!)
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Vibe Check").font(.title3).fontWeight(.bold).foregroundColor(.white).padding(.horizontal)
                                    
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.vibes, id: \.title) { vibe in
                                            VibeCard(vibe: vibe) {
                                                withAnimation { viewModel.selectedVibe = vibe.title }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subcomponents

struct FilterBadge: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primaryAccent)
        .foregroundColor(.black)
        .cornerRadius(20)
    }
}

struct TrendingCard: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 100)
                
                Text(location.currentStatus.title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(location.currentStatus.color)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name).font(.headline).foregroundColor(.white).lineLimit(1)
                Text(location.category).font(.caption).foregroundColor(.secondaryText)
            }
            .padding(10)
        }
        .frame(width: 160)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct VibeCard: View {
    let vibe: VibeOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: vibe.icon)
                    .font(.title2)
                    .foregroundColor(vibe.color)
                    .padding(10)
                    .background(vibe.color.opacity(0.2))
                    .clipShape(Circle())
                
                Text(vibe.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
