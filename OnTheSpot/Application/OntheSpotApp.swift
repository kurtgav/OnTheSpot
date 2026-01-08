import SwiftUI

@main
struct OnTheSpotApp: App {
    
    // ADD THIS INIT BLOCK 👇
    init() {
        // This asks the user for permission as soon as the app launches
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
