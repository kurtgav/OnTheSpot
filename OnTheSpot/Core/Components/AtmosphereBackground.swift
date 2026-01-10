import SwiftUI

struct AtmosphereBackground: View {
    var color: Color
    
    var body: some View {
        ZStack {
            // Use a simple Gradient instead of heavy Blur for performance
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.3),
                    Color(UIColor.systemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}
