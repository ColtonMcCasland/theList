//
//  AddNodeView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/24/23.
//

import SwiftUI

struct AddNodeView: View {
    @Binding var isShowing: Bool
    @Binding var newNodeTitle: String
    let addNodeAction: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .onTapGesture {
                    isShowing = false
                }
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Add Node")
                    .font(.headline)
                TextField("Node Title", text: $newNodeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Add") {
                    addNodeAction()
                    isShowing = false
                }
                .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
