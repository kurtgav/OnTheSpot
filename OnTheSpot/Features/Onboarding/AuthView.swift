import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Binding var appState: AppState
    @ObservedObject var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var isLoading = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            AtmosphereBackground(color: .blue).opacity(0.2)
            
            VStack(spacing: 25) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "location.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.primaryAccent)
                        .padding(.bottom, 10)
                    
                    Text(isLoginMode ? "Welcome\nBack." : "Create\nAccount.")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                if let error = authManager.authError {
                    Text(error).font(.caption).foregroundColor(.red)
                }
                
                // Inputs
                VStack(spacing: 16) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Email Button
                Button(action: handleAuthAction) {
                    HStack {
                        if isLoading { ProgressView() } else {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .font(.headline).fontWeight(.bold).foregroundColor(.black)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.primaryAccent).cornerRadius(30)
                }
                .disabled(isLoading)
                
                // --- SOCIAL LOGIN ---
                HStack(spacing: 20) {
                    // Google
                    Button(action: {
                        authManager.signInWithGoogle { success in
                            if success { withAnimation { appState = .home } }
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe") // Replace with Google Logo asset if you have it
                            Text("Google")
                        }
                        .font(.headline).foregroundColor(.black)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.white).cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    
                    // Apple
                    Button(action: {
                        authManager.startSignInWithAppleFlow()
                        // Note: Success handled in delegate, auto-navigates via RootView
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Apple")
                        }
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.black).cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
                
                Spacer()
                
                // Toggle
                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    HStack(spacing: 4) {
                        Text(isLoginMode ? "New here?" : "Have an account?")
                            .foregroundColor(.gray)
                        Text(isLoginMode ? "Sign Up" : "Log In")
                            .fontWeight(.bold).foregroundColor(.primaryAccent)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { showContent = true }
        }
    }
    
    func handleAuthAction() {
        isLoading = true
        if isLoginMode {
            authManager.signIn(email: email, password: password) { success in
                isLoading = false
                if success { withAnimation { appState = .home } }
            }
        } else {
            authManager.signUp(email: email, password: password) { success in
                isLoading = false
                if success {
                    DispatchQueue.main.async { withAnimation { appState = .setupProfile } }
                }
            }
        }
    }
}

// Keeping CustomTextField...
struct CustomTextField: View {
    var icon: String; var placeholder: String; @Binding var text: String; var isSecure: Bool = false
    @State private var showPassword = false
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 20)
            if isSecure && !showPassword { SecureField(placeholder, text: $text).foregroundColor(Color.primary) }
            else { TextField(placeholder, text: $text).foregroundColor(Color.primary) }
            if isSecure {
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill").foregroundColor(.gray)
                }
            }
        }
        .padding().background(Color.gray.opacity(0.1)).cornerRadius(20)
    }
}
