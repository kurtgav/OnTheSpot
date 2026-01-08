import SwiftUI

struct AtmosphereBackground: View {
    var color: Color = .primaryAccent
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            // Top Left Glow
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -100, y: -200)
            
            // Bottom Right Glow
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 100, y: 200)
        }
    }
}
