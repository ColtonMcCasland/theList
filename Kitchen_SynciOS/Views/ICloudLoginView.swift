import SwiftUI
import AuthenticationServices
import CloudKit

struct ICloudLoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var appleIDCredential: ASAuthorizationAppleIDCredential?
    
    var body: some View {
        Group {
            if isLoggedIn {
                ListView()
            } else {
                VStack {
                    // Your UI code for the iCloud login view
                    
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignInWithApple(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(width: 200, height: 44)
                }
                .padding()
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    private func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                self.appleIDCredential = appleIDCredential
                handleSignInWithApple()
            }
        case .failure(let error):
            // Handle sign in error
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    private func handleSignInWithApple() {
        guard let credential = appleIDCredential else { return }
        
        // Use the credential to authenticate the user and perform necessary actions
        print("Sign in with Apple successful")
        print("User Identifier: \(credential.user)")
        print("Email: \(credential.email ?? "N/A")")
        print("Full Name: \(credential.fullName?.description ?? "N/A")")
        
        let container = CKContainer.default()
        container.accountStatus { accountStatus, error in
            if let error = error {
                print("Error fetching user account status: \(error.localizedDescription)")
                return
            }
            
            if accountStatus == .available {
                // User is logged in
                // Perform necessary actions or navigate to the next view
                print("User is logged in")
                isLoggedIn = true
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
            } else {
                // User is not logged in or iCloud is not available
                print("User is not logged in or iCloud is not available")
            }
        }
    }
}

struct ICloudLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ICloudLoginView()
    }
}
