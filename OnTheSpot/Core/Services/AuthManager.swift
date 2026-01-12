import SwiftUI
import Combine
import FirebaseAuth
import FirebaseCore // Fixes 'FirebaseApp' error
import GoogleSignIn
import AuthenticationServices

class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()
    
    @Published var user: User?
    @Published var authError: String?
    
    fileprivate var currentNonce: String?
    
    override init() {
        super.init()
        Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
        }
    }
    
    // MARK: - EMAIL / PASSWORD
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.handleAuthResult(result: result, error: error, completion: completion)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.handleAuthResult(result: result, error: error, completion: completion)
        }
    }
    
    // MARK: - GOOGLE SIGN IN (Fixed for latest SDK)
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.configuration = config
        
        // Updated signIn method signature
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                self.authError = error.localizedDescription
                completion(false)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                self.handleAuthResult(result: result, error: error, completion: completion)
            }
        }
    }
    
    // MARK: - APPLE SIGN IN
    func startSignInWithAppleFlow() {
        let nonce = CryptoUtils.randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoUtils.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut() // Sign out of Google too
    }
    
    private func handleAuthResult(result: AuthDataResult?, error: Error?, completion: @escaping (Bool) -> Void) {
        if let error = error {
            self.authError = error.localizedDescription
            completion(false)
        } else {
            self.authError = nil
            CloudDataManager.shared.fetchUserProfile()
            DataManager.shared.loadProfileImage()
            completion(true)
        }
    }
}

// MARK: - Apple Delegate
extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else { return }
            guard let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            
            // method for latest Firebase SDK
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: nil)
            
            // lets use the most generic one that usually works:
            Auth.auth().signIn(with: credential) { result, error in
                if result != nil {
                    CloudDataManager.shared.fetchUserProfile()
                    DataManager.shared.loadProfileImage()
                } else {
                    self.authError = error?.localizedDescription
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Error: \(error)")
    }
}
