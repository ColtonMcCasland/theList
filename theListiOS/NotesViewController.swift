import UIKit
import CoreData

class NotesViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var imageView: UIImageView!
	
	var userList: UserList?
	var persistenceController = PersistenceController.shared
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.delegate = self
		loadNotes()
	}
	
	func loadNotes() {
		guard let notesField = userList?.notesField else { return }
		textView.text = notesField.content
		if let imageData = notesField.imageData {
			imageView.image = UIImage(data: imageData)
		}
	}
	
	func saveNotes() {
		guard let userList = userList else {
			print("UserList is nil")
			return
		}
		
		var notesField: NotesField
		if let existingNotesField = userList.notesField {
			notesField = existingNotesField
		} else {
			notesField = NotesField(context: persistenceController.container.viewContext)
			notesField.id = UUID()
			userList.notesField = notesField
		}
		
		notesField.content = textView.text
		print("Saving content: \(String(describing: textView.text))") // Debugging
		
		if let image = imageView.image {
			notesField.imageData = image.pngData()
		}
		
		do {
			try persistenceController.container.viewContext.save()
			print("Content saved successfully") // Debugging
		} catch {
			print("Error saving notes content: \(error)")
		}
	}

	
	// UITextViewDelegate method to detect changes to the text view's content
	func textViewDidChange(_ textView: UITextView) {
		saveNotes()
	}
	
	// Add other methods to handle editing, adding images, etc.
}
