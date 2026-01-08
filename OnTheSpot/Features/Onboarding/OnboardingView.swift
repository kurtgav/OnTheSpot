import SwiftUI

struct OnboardingView: View {
    @Binding var appState: AppState
    
    // Animation States
    @State private var textOpacity = 0.0
    @State private var textScale = 0.8
    @State private var buttonOffset: CGFloat = 100
    @State private var iconScale: CGFloat = 0.1
    
    var body: some View {
        ZStack {
            // 1. Deep Space Background
            Color.appBackground.ignoresSafeArea()
            
            // 2. The Shooting Stars Layer
            ForEach(0..<15, id: \.self) { _ in
                ShootingStar()
            }
            
            // 3. Central Content
            VStack(spacing: 30) {
                Spacer()
                
                // --- THE GLOWING ICON IS BACK ---
                ZStack {
                    // Outer Glow
                    Circle()
                        .fill(Color.primaryAccent)
                        .frame(width: 180, height: 180)
                        .blur(radius: 60)
                        .opacity(0.3)
                    
                    // The Icon
                    Image(systemName: "location.viewfinder")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .shadow(color: Color.primaryAccent.opacity(0.8), radius: 20, x: 0, y: 0)
                }
                .scaleEffect(iconScale)
                
                // --- THE BRAND TEXT ---
                VStack(spacing: 0) {
                    Text("ON THE")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .tracking(8)
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(.bottom, 5)
                    
                    Text("SPOT")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .primaryAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .primaryAccent.opacity(0.5), radius: 30, x: 0, y: 10)
                }
                .opacity(textOpacity)
                .scaleEffect(textScale)
                
                Spacer()
                // Typography
                VStack(spacing: 16) {
                    Text("Spot it. Share it.\nSkip the Line.")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Real-time crowd updates for your campus.\nKnow before you go.")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                // 4. Action Button
                Button(action: {
                    withAnimation(.spring()) {
                        appState = .authentication
                    }
                }) {
                    HStack {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primaryAccent)
                    .cornerRadius(30)
                    .shadow(color: Color.primaryAccent.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
                .offset(y: buttonOffset)
            }
        }
        .onAppear {
            // Orchestrate the Entrance Animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0 // Pop the icon in
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                textOpacity = 1.0
                textScale = 1.0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8)) {
                buttonOffset = 0
            }
        }
    }
}

// MARK: - Shooting Star Component
struct ShootingStar: View {
    @State private var startX = Double.random(in: -100...300)
    @State private var startY = Double.random(in: -200...200)
    @State private var animationDuration = Double.random(in: 2.0...4.0)
    @State private var delay = Double.random(in: 0.0...2.0)
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing))
            .frame(width: 80, height: 2)
            .overlay(Circle().fill(Color.white).frame(width: 4, height: 4), alignment: .trailing)
            .rotationEffect(.degrees(45))
            .position(x: startX, y: startY)
            .offset(x: offset, y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: false).delay(delay)) {
                    offset = 600
                    opacity = 1.0
                }
            }
    }
}
