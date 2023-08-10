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
	
	@State private var opacity: Double = 1
	@State private var offset: CGFloat = 0
	
	var body: some View {
		ZStack {
			// Background tap gesture
			Color.clear
				.contentShape(Rectangle())
				.onTapGesture {
					dismissView()
				}
			
			// Card view
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
						dismissView()
					}
					.padding()
				}
				.background(Color.white)
				.cornerRadius(25)
				.shadow(radius: 10)
				.padding()
			}
			.offset(y: offset)
			.opacity(opacity)
			.animation(.spring())
			.onAppear {
				withAnimation {
					opacity = 1
					offset = 0
				}
			}
			.edgesIgnoringSafeArea(.all)
		}
	}
	
	private func dismissView() {
		withAnimation {
			opacity = 0
			offset = UIScreen.main.bounds.height
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			showingAddItemView = false
			resetView()
		}
	}
	
	private func resetView() {
		opacity = 1
		offset = 0
	}
}
