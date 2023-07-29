import SwiftUI
import AuthenticationServices
import CloudKit
import CoreData

struct ICloudLoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var appleIDCredential: ASAuthorizationAppleIDCredential?
    @Environment(\.managedObjectContext) private var viewContext // Access the managedObjectContext

    var body: some View {
        Group {
            if isLoggedIn {
                MainView()
            } else {
                VStack {
                    Text("Welcome to Kitchen Sync")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    Text("Please sign in with your Apple ID to continue")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 50)
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignInWithApple(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(width: 200, height: 44)
                    .padding(.top, 50)
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
        
        // Rest of your code...
        
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
