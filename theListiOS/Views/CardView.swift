import SwiftUI

@available(iOS 15.0, *)
struct CardView: View {
	let content: AnyView
	let offset: CGFloat
	
	var body: some View {
		content
			.frame(width: 300, height: 200) // Set the size of the card
			.padding(20) // Padding around the content
			.background(Color.white)
			.cornerRadius(15) // Corner radius for a softer appearance
			.shadow(radius: 10) // Shadow for a more pronounced effect
			.offset(y: offset) // Apply vertical offset
	}
}
