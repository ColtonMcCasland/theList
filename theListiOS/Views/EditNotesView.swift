import SwiftUI


struct EditNotesView: View {
	@State private var text = ""
	@FocusState private var isTextEditorFocused: Bool
	var isFocused: Bool
	
	var body: some View {
		TextEditor(text: $text)
			.font(.system(size: 18))
			.lineSpacing(10)
			.background(Color.clear)
			.padding(.horizontal) // Horizontal padding only
			.focused($isTextEditorFocused, equals: isFocused) // Control the focus state
	}
}
