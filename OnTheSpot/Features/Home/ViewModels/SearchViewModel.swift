import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil
    @Published var selectedVibe: String? = nil // New: Filter by Vibe
    
    // Connect to the main data
    @Published var allLocations: [Location] = Location.mockData
    
    // Categories
    let categories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking"]
    
    // Quick Vibes
    let vibes = [
        VibeOption(title: "Quiet", icon: "waveform.path.ecg", color: .purple, relatedStatuses: [.quiet]),
        VibeOption(title: "No Queue", icon: "figure.walk", color: .green, relatedStatuses: [.noLine, .shortLine, .available]),
        VibeOption(title: "Busy", icon: "flame.fill", color: .orange, relatedStatuses: [.longLine, .noisy, .inUse])
    ]
    
    // --- SMART FILTERING LOGIC ---
    var filteredLocations: [Location] {
        // 1. Start with everything
        var result = allLocations
        
        // 2. Filter by Search Text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 3. Filter by Category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // 4. Filter by Vibe
        if let vibeTitle = selectedVibe,
           let vibe = vibes.first(where: { $0.title == vibeTitle }) {
            result = result.filter { vibe.relatedStatuses.contains($0.currentStatus) }
        }
        
        return result
    }
    
    // Helper: Are we currently filtering?
    var isFiltering: Bool {
        return !searchText.isEmpty || selectedCategory != nil || selectedVibe != nil
    }
    
    // Helper: Clear Everything
    func clearAll() {
        searchText = ""
        selectedCategory = nil
        selectedVibe = nil
    }
    
    var trendingLocations: [Location] {
        return Array(allLocations.prefix(3)) // Mock trending
    }
}

// Helper Struct for Vibes
struct VibeOption {
    let title: String
    let icon: String
    let color: Color
    let relatedStatuses: [LocationStatus]
}
