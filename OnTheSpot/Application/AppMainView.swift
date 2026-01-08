import SwiftUI

struct AppMainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Adaptive background (works for Dark & Light mode)
        appearance.backgroundColor = UIColor(Color.appBackground)
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primaryAccent)]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "map.fill") }

            SearchView()
                .tabItem { Label("Discover", systemImage: "magnifyingglass") }
            
            // --- FIXED: CONNECTING THE REAL NOTIFICATION VIEW ---
            NotificationView()
                .tabItem { Label("Activity", systemImage: "bell.fill") }
            // ----------------------------------------------------
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(.primaryAccent)
    }
}
