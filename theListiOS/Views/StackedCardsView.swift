import SwiftUI

struct StackedCardsView: View {
	var body: some View {
		ScrollView {
			VStack(spacing: 20) { // Spacing between cards
				ForEach(0..<6) { index in
					CardView(itemCount: index < 3 ? 3 : 10) // Conditionally set the number of items
						.animation(.spring()) // Subtle animation for elegance
				}
			}
			.padding(.vertical, 20) // Vertical padding for elegance
		}
	}
}

@available(iOS 15.0, *)
struct CardView: View {
	let itemCount: Int
	@State private var isCompleted: [Bool] // State for each item's completion status
	
	init(itemCount: Int) {
		self.itemCount = itemCount
		self._isCompleted = State(initialValue: Array(repeating: false, count: itemCount))
	}
	
	var body: some View {
		ZStack {
			VStack {
				Text("Title").font(.title)
				Spacer()
				itemListView
			}
			.frame(maxWidth: .infinity) // Allow the width to take up available space
			.padding(10) // Padding around the content
			.background(Color.white)
			.cornerRadius(20) // Increased corner radius for a softer appearance
			.shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Subtle shadow for elegance
		
		}
	}
	
	var itemListView: some View {
		VStack {
			ForEach(0..<itemCount, id: \.self) { index in
				HStack {
					Text("Item \(index + 1)")
						.font(.subheadline) // Adjusted font size
					Text("Description \(index + 1)")
						.font(.subheadline) // Adjusted font size
					Spacer()
					Image(systemName: isCompleted[index] ? "checkmark.circle.fill" : "circle")
						.resizable() // Make the image resizable
						.frame(width: 20, height: 20) // Adjusted frame size for the image
						.onTapGesture {
							isCompleted[index].toggle()
						}
				}
			}
		}
	}
}
