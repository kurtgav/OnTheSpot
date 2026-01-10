import SwiftUI
import Combine
import FirebaseAuth

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var user: User?
    @Published var authError: String?
    
    private init() {
        // Listen for login changes automatically
        Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
        }
    }
    
    // 1. SIGN UP
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(" Sign Up Error: \(error.localizedDescription)")
                self.authError = error.localizedDescription
                completion(false)
            } else {
                print(" Sign Up Success for: \(email)")
                self.authError = nil
                completion(true)
            }
        }
    }
    
    // 2. LOG IN (Updated to fetch profile)
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.authError = error.localizedDescription
                completion(false)
            } else {
                self.authError = nil
                
                // CRITICAL FIX: Fetch Profile IMMEDIATELY
                CloudDataManager.shared.fetchUserProfile()
                DataManager.shared.loadProfileImage()
                
                completion(true)
            }
        }
    }
    
    // 3. LOG OUT
    func signOut() {
        try? Auth.auth().signOut()
    }
}
