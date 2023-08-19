//
//  StackedCardsView.swift
//  theList
//
//  Created by Colton McCasland on 8/18/23.
//

import SwiftUI

struct StackedCardsView: View {
	@State private var selectedIndex: Int? = nil
	
	var body: some View {
		ZStack {
			// Cards
			VStack(spacing: -180) { // Negative spacing to create a close-stacked effect
				ForEach(0..<3) { index in
					CardView(content: AnyView(EditNotesView(isFocused: selectedIndex == index)), offset: offset(for: index))
						.gesture(
							TapGesture()
								.onEnded { _ in
									if selectedIndex != index {
										selectedIndex = index
									} else {
										closeKeyboard()
									}
								}
						)
						.contentShape(Rectangle()) // Ensure the entire card is tappable
				}
			}
			.offset(y: 180) // Offset the entire stack to position it at the bottom
			.background(
				// Background tap gesture to deselect the card and close the keyboard
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture {
						selectedIndex = nil
						closeKeyboard()
					}
			)
		}
		.animation(.default) // Animate transitions
	}
	
	// Calculate the vertical offset for a given index
	private func offset(for index: Int) -> CGFloat {
		return selectedIndex == index ? -150 : 0
	}
	
	// Function to close the keyboard
	private func closeKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
