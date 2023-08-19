import SwiftUI

struct EditNotesView: View {
	@State private var text = ""
	
	var body: some View {
		VStack(spacing: 0) {
			
			// Text Editor without lined paper pattern
			TextEditor(text: $text)
				.font(.system(size: 18))
				.lineSpacing(10)
				.background(Color.clear)
				.padding(.horizontal) // Horizontal padding only
		}
		.background(Color(UIColor.systemBackground))
		.edgesIgnoringSafeArea(.all)
	}
}

struct ListView_Previews: PreviewProvider {
	static var previews: some View {
		EditNotesView()
	}
}
