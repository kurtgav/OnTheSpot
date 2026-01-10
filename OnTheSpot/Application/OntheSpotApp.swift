import SwiftUI
import FirebaseCore // Import the SDK

// 1. The Delegate (Handles Firebase setup)
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure() // The magic line that connects to Google
    return true
  }
}

@main
struct OnTheSpotApp: App {
    // 2. Connect the Delegate to the App
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Keep our existing Notification Permission logic
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
