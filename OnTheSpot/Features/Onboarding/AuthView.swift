import SwiftUI

struct AuthView: View {
    @Binding var appState: AppState
    
    // Form States
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true // Toggle between Login and Sign Up
    
    // Animation States
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // 1. Consistent Background
            Color.appBackground.ignoresSafeArea()
            
            // 2. Shooting Stars (Keeps the vibe alive)
            ForEach(0..<10, id: \.self) { _ in
                ShootingStar()
                ShootingStar()
            }
            
            VStack(spacing: 25) {
                // --- Header Section ---
                VStack(alignment: .leading, spacing: 8) {
                    // Small animated logo
                    Image(systemName: "location.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.primaryAccent)
                        .padding(.bottom, 10)
                        .shadow(color: .primaryAccent.opacity(0.6), radius: 10)
                    
                    Text(isLoginMode ? "Welcome\nBack." : "Create\nAccount.")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineSpacing(0)
                    
                    Text(isLoginMode ? "Sign in to start spotting." : "Join the network.")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // --- Input Fields (Glassmorphism) ---
                VStack(spacing: 16) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring().delay(0.1), value: showContent)
                    
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring().delay(0.2), value: showContent)
                    
                    if isLoginMode {
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Forgot password action
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        }
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring().delay(0.25), value: showContent)
                    }
                }
                
                Spacer()
                
                // --- Main Action Button ---
                Button(action: {
                    // Simulate Success -> Go Home
                    withAnimation(.spring()) {
                        appState = .home
                    }
                }) {
                    HStack {
                        Text(isLoginMode ? "Log In" : "Sign Up")
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
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
                .animation(.spring().delay(0.3), value: showContent)
                
                // --- Social Divider ---
                HStack {
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Text("OR").font(.caption).fontWeight(.bold).foregroundColor(.secondaryText)
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                }
                .padding(.vertical, 10)
                .opacity(showContent ? 1 : 0)
                .animation(.spring().delay(0.4), value: showContent)
                
                // --- Social Buttons ---
                HStack(spacing: 20) {
                    SocialButton(iconName: "apple.logo")
                    SocialButton(iconName: "g.circle.fill") // Using generic G circle for Google
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring().delay(0.5), value: showContent)
                
                // --- Toggle Mode ---
                Button(action: {
                    withAnimation(.easeInOut) {
                        isLoginMode.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isLoginMode ? "Don't have an account?" : "Already have an account?")
                            .foregroundColor(.secondaryText)
                        Text(isLoginMode ? "Sign Up" : "Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.primaryAccent)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.spring().delay(0.6), value: showContent)
            }
            .padding(30)
        }
        .onAppear {
            // Trigger Entrance Animation
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Reusable Glass Text Field
struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.secondaryText)
                .frame(width: 20)
            
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.3))
                    }
                    .foregroundColor(.white)
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.3))
                    }
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08)) // Glass Effect
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Social Button Component
struct SocialButton: View {
    var iconName: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white.opacity(0.08))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// MARK: - Helper for Placeholder Color
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(appState: .constant(.authentication))
    }
}
