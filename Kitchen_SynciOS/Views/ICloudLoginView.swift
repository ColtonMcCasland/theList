import SwiftUI
import AuthenticationServices
import CloudKit
import CoreData

struct ICloudLoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var appleIDCredential: ASAuthorizationAppleIDCredential?
    @Environment(\.managedObjectContext) private var viewContext // Access the managedObjectContext
    @State private var listNode: ListNode? // Add this line

    var body: some View {
        Group {
            if isLoggedIn {
                if let listNode = listNode {
                    ListView(listNode: listNode)
                } else {
                    Text("No list node available")
                }
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
        if isLoggedIn {
            // Fetch the first ListNode from CoreData
            let fetchRequest: NSFetchRequest<ListNode> = ListNode.fetchRequest()
            fetchRequest.fetchLimit = 1
            do {
                let fetchedListNodes = try viewContext.fetch(fetchRequest)
                listNode = fetchedListNodes.first
            } catch {
                // Handle the error
            }
        }
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

                // Create a new User entity with the user's iCloud email
                let context = PersistenceController.shared.container.viewContext
                let user = User(context: context)
                user.email = credential.email ?? "test@icloud.com" // Use a fake iCloud account for the simulator
                do {
                    try context.save()
                } catch {
                    print("Error saving user: \(error)")
                }
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
