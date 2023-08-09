import SwiftUI

struct NotesView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@ObservedObject var userList: UserList
	
	@State private var content: String = ""
	
	var body: some View {
		VStack {
			TextEditor(text: $content)
				.onAppear {
					loadNotes()
				}
				.onChange(of: content) { newValue in
					saveNotes()
				}
			// Add other UI elements for images, etc.
		}
		.navigationBarTitle(userList.title ?? "Unknown List", displayMode: .inline)
	}
	
	private func loadNotes() {
		content = userList.notesField?.content ?? ""
	}
	
	private func saveNotes() {
		if userList.notesField == nil {
			userList.notesField = NotesField(context: viewContext)
			userList.notesField?.id = UUID()
		}
		userList.notesField?.content = content
		
		do {
			try viewContext.save()
		} catch {
			print("Error saving notes content: \(error)")
		}
	}
}
