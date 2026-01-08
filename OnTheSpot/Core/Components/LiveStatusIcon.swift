import SwiftUI

struct LiveStatusIcon: View {
    let status: LocationStatus
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Pulse Effect
            Circle()
                .stroke(status.color.opacity(0.5), lineWidth: 2)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0.0 : 1.0)
            
            // Background Circle
            Circle()
                .fill(Color.appBackground)
                .frame(width: 40, height: 40)
                .shadow(color: status.color.opacity(0.5), radius: 5, x: 0, y: 2)
            
            // The Icon
            Image(systemName: status.iconName)
                .foregroundColor(status.color)
                .font(.system(size: 18, weight: .bold))
        }
        .frame(width: 44, height: 44)
        .onAppear {
            withAnimation(Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}
