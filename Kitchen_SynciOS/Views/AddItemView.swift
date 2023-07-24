//
//  AddItemView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/24/23.
//

import SwiftUI

struct AddItemView: View {
    @Binding var isShowing: Bool
    @Binding var title: String
    let addItemAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a new item")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addItemAction()
                isShowing = false
            }) {
                Text("Add Item")
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}
