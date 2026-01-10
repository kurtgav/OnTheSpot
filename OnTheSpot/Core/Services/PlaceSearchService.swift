import Foundation
import MapKit
import Combine

class PlaceSearchService: ObservableObject {
    @Published var searchResults: [MKMapItem] = []
    @Published var query: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search so we don't spam Apple servers while typing
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        // 1. Create Request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        // 2. Scope to user location (if available in HomeViewModel, passed conceptually)
        // For MVP we search generally, or you can pass a region here.
        
        // 3. Run Search
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                DispatchQueue.main.async {
                    self.searchResults = items
                }
            }
        }
    }
}
