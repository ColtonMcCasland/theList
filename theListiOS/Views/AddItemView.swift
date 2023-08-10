//
//  AddItemView.swift
//  theList
//
//  Created by Colton McCasland on 8/9/23.
//

import SwiftUI


struct AddItemView: View {
	@Binding var showingAddItemView: Bool
	
	@State private var title: String = ""
	@State private var tag: String = ""
	@State private var color: String = ""
	@State private var priority: String = "optional"
	
	var body: some View {
		VStack {
			VStack {
				TextField("Title", text: $title)
					.padding()
				TextField("Tag", text: $tag)
					.padding()
				TextField("Color", text: $color)
					.padding()
				Picker("Priority", selection: $priority) {
					Text("Optional").tag("optional")
					Text("Required").tag("required")
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding()
				Button("Add Item") {
					// Handle adding the item here
					withAnimation {
						showingAddItemView = false
					}
				}
				.padding()
			}
			.background(Color.white)
			.cornerRadius(20)
			.padding()
		}
		.edgesIgnoringSafeArea(.all)
	}
}
