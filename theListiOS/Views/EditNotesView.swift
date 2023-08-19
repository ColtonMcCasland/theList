import SwiftUI

struct EditNotesView: View {
	@State private var title = ""
	@State private var bodyText = ""
	@FocusState private var isTitleFocused: Bool
	@FocusState private var isBodyFocused: Bool
	var isFocused: Bool
	
	var body: some View {
		VStack(alignment: .center, spacing: 5) {
			// Title input field with bold, centered, and slightly bigger text
			TextField("Enter title here...", text: $title)
				.font(.system(size: 22, weight: .bold))
				.multilineTextAlignment(.center)
				.padding(.horizontal)
				.focused($isTitleFocused, equals: isFocused)
			
			// Body input field (rest of the text)
			TextEditor(text: $bodyText)
				.font(.system(size: 18))
				.lineSpacing(10)
				.background(Color.clear)
				.padding(.horizontal) // Horizontal padding only
				.focused($isBodyFocused, equals: isFocused)
		}
	}
}
