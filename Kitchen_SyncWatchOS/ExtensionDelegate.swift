//
//  ExtensionDelegate.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/9/23.
//

import Foundation
import SwiftUI
import WatchConnectivity


class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate, ObservableObject {
    @Published var receivedMessage: String?
    @Published var isMessageReceived = false

    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let messageText = message["message"] as? String {
            receivedMessage = messageText
            isMessageReceived = true
        }
    }
    
    // Function to retreive records from ios app
}

