import SwiftUI

struct AppMainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground.opacity(0.9))
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primaryAccent)]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.secondaryText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.secondaryText)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "map.fill") }

            // UPDATED: Now uses the new SearchView
            SearchView()
                .tabItem { Label("Discover", systemImage: "magnifyingglass") }
            
            Text("Notifications")
                .tabItem { Label("Notifications", systemImage: "bell.fill") }
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(.primaryAccent)
    }
}
