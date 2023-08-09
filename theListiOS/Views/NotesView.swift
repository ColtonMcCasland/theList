import SwiftUI

struct NotesView: View {
	@State private var text = ""
	
	var body: some View {
		TextEditor(text: $text)
			.padding()
			.navigationBarTitle("Notes", displayMode: .inline)
	}
}
