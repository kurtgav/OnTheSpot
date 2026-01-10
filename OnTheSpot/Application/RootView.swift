import SwiftUI
import FirebaseAuth

enum AppState {
    case onboarding
    case authentication
    case setupProfile
    case home
}

struct RootView: View {
    @State private var currentState: AppState = .onboarding
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        ZStack {
            switch currentState {
            case .onboarding:
                OnboardingView(appState: $currentState)
                    .transition(.opacity)
            case .authentication:
                AuthView(appState: $currentState)
                    .transition(.move(edge: .trailing))
            case .setupProfile:
                ProfileSetupView(appState: $currentState)
                    .transition(.move(edge: .trailing))
            case .home:
                AppMainView()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentState)
        .preferredColorScheme(dataManager.isDarkMode ? .dark : .light)
        .onAppear {
            // ONLY AUTO-LOGIN IF WE ARE IN ONBOARDING STATE
            // This prevents it from hijacking the flow if we just signed up
            if currentState == .onboarding && Auth.auth().currentUser != nil {
                print("Auto-Login Detected")
                currentState = .home
                CloudDataManager.shared.fetchUserProfile()
            }
        }
    }
}
