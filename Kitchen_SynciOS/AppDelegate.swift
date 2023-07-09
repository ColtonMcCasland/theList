//
//  AppDelegate.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/9/23.
//

import Foundation
import SwiftUI
import WatchConnectivity

class AppDelegate: NSObject, UIApplicationDelegate, WCSessionDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        return true
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Code to manage an inactive session
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Code to manage a deactivated session
        WCSession.default.activate()
    }

    func sendMessage() {
        let session = WCSession.default
        if session.activationState == .activated {
            session.sendMessage(["message": "Hello, Apple Watch!"], replyHandler: nil, errorHandler: nil)
        }
    }
}
