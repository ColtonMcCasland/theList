//
//  ContentView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/8/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var extensionDelegate: ExtensionDelegate

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MessageView(message: extensionDelegate.receivedMessage), isActive: $extensionDelegate.isMessageReceived) {
                    Text("Check for Messages")
                }
            }
        }
    }
}

struct MessageView: View {
    var message: String?

    var body: some View {
        VStack {
            Text("Received Message:")
            if let message = message {
                Text(message)
            } else {
                Text("No message received.")
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
