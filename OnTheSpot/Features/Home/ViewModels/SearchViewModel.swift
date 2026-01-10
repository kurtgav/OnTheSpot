import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil
    @Published var selectedVibe: String? = nil
    
    @Published var allLocations: [Location] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let categories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking"]
    
    let vibes = [
        VibeOption(title: "Quiet / Chill", icon: "waveform.path.ecg", color: .purple, relatedStatuses: [.quiet, .justRight]),
        VibeOption(title: "Quick / Open", icon: "figure.walk", color: .green, relatedStatuses: [.noLine, .shortLine, .available]),
        VibeOption(title: "Busy / Full", icon: "flame.fill", color: .orange, relatedStatuses: [.longLine, .noisy, .inUse])
    ]
    
    init() {
        // CRITICAL FIX: Listen to CloudDataManager
        CloudDataManager.shared.$locations
            .receive(on: DispatchQueue.main)
            .assign(to: \.allLocations, on: self)
            .store(in: &cancellables)
    }
    
    // ... (Keep existing filtering logic) ...
    var filteredLocations: [Location] {
        var result = allLocations
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if let vibeTitle = selectedVibe,
           let vibe = vibes.first(where: { $0.title == vibeTitle }) {
            result = result.filter { vibe.relatedStatuses.contains($0.currentStatus) }
        }
        
        return result.sorted { score(for: $0.currentStatus) > score(for: $1.currentStatus) }
    }
    
    func score(for status: LocationStatus) -> Int {
        switch status {
        case .quiet, .noLine, .available: return 3
        case .justRight, .shortLine: return 2
        case .noisy, .longLine, .inUse: return 1
        }
    }
    
    var isFiltering: Bool { !searchText.isEmpty || selectedCategory != nil || selectedVibe != nil }
    func toggleCategory(_ category: String) { selectedCategory = (selectedCategory == category) ? nil : category }
    func toggleVibe(_ vibeTitle: String) { selectedVibe = (selectedVibe == vibeTitle) ? nil : vibeTitle }
    func clearAll() { searchText = ""; selectedCategory = nil; selectedVibe = nil }
    var trendingLocations: [Location] { Array(allLocations.prefix(3)) }
}

struct VibeOption {
    let title: String; let icon: String; let color: Color; let relatedStatuses: [LocationStatus]
}
