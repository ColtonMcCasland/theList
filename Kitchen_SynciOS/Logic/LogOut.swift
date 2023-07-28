import Foundation

func logOut() {
    // Perform any necessary log out actions here...

    // Then set isLoggedIn to false to return to the ICloudLoginView
    UserDefaults.standard.set(false, forKey: "isLoggedIn")
}
