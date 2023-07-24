//
//  AddListView.swift
//  Kitchen_Sync
//
//  Created by Colton McCasland on 7/24/23.
//
import SwiftUI

struct AddListView: View {
    @Binding var isShowing: Bool
    @Binding var title: String
    let addListAction: () -> Void

    var body: some View {
        VStack {
            Text("Add a new list")
                .font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addListAction()
                isShowing = false
            }) {
                Text("Add List")
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}


