//
//  AddNodeView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/24/23.
//

import SwiftUI

struct AddNodeView: View {
    @Binding var isShowing: Bool
    @Binding var title: String
    let addNodeAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a new node")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addNodeAction()
                isShowing = false
            }) {
                Text("Add Node")
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}
