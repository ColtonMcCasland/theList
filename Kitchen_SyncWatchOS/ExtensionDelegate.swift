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
    let watchManager = WatchManager()

    @Published var receivedMessage: String?
    @Published var isMessageReceived = false
    
    var records = [[String: Any]]()
    
    func willActivate() {
           // This method is called when watch view controller is about to be visible to user
           WKExtension.shared().isFrontmostTimeoutExtended = true
           WatchManager.shared.sendNodeItemsToiOSApp()
           WatchManager.shared.requestNodeItemsFromiOSApp() // Add this line
       }


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
          if let records = message["records"] as? [[String: Any]] {
              self.records = records
          }
      }
    
    // Function to retreive records from ios app
}

