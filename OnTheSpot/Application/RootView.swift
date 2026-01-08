import SwiftUI

// Define the state ONLY here
enum AppState {
    case onboarding
    case authentication
    case home
}

struct RootView: View {
    // Start at onboarding
    @State private var currentState: AppState = .onboarding
    
    var body: some View {
        ZStack {
            switch currentState {
            case .onboarding:
                OnboardingView(appState: $currentState)
                    .transition(.opacity.animation(.easeInOut))
            case .authentication:
                AuthView(appState: $currentState)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .home:
                AppMainView() // Your existing Tab View
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentState)
    }
}
