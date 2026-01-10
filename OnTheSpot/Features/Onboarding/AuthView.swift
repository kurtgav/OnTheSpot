import SwiftUI

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
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "location.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.primaryAccent)
                        .padding(.bottom, 10)
                    
                    Text(isLoginMode ? "Welcome\nBack." : "Create\nAccount.")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(0)
                    
                    Text(isLoginMode ? "Sign in to start spotting." : "Join the network.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Error Message (If any)
                if let error = authManager.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Inputs
                VStack(spacing: 16) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // ACTION BUTTON
                Button(action: handleAuthAction) {
                    HStack {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .font(.headline).fontWeight(.bold).foregroundColor(.black)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.primaryAccent).cornerRadius(30)
                    .shadow(color: Color.primaryAccent.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                .disabled(isLoading)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
                
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
                .opacity(showContent ? 1 : 0)
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
            // LOGIN
            print("🔄 Attempting Login...")
            authManager.signIn(email: email, password: password) { success in
                isLoading = false
                if success {
                    print("🚀 Login Success -> Home")
                    withAnimation { appState = .home }
                }
            }
        } else {
            // SIGN UP
            print("🔄 Attempting Sign Up...")
            authManager.signUp(email: email, password: password) { success in
                isLoading = false
                if success {
                    print("🚀 Sign Up Success -> Setup Profile")
                    
                    // FORCE MAIN THREAD UPDATE
                    DispatchQueue.main.async {
                        withAnimation {
                            appState = .setupProfile
                        }
                    }
                }
            }
        }
    }
}
// Updated CustomTextField with Password Toggle
struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @State private var showPassword = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color.primary) // Fix for light mode
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Color.primary) // Fix for light mode
            }
            
            if isSecure {
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}
