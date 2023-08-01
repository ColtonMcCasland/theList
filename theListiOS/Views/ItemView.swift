import SwiftUI
import UniformTypeIdentifiers

struct ItemView: View {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.managedObjectContext) private var viewContext
	@ObservedObject var item: GroceryItem
	
	var body: some View {
		Button(action: {
			item.isBought.toggle()
			do {
				try viewContext.save()
			} catch {
				// handle the Core Data error
			}
			if let store = item.store {
				checkAndDeleteStoreIfAllItemsBought(store: store)
			}
		}) {
			HStack {
				Text(item.name ?? "Unspecified")
					.strikethrough(item.isBought)
				
				if item.priority == "Required" {
					Text("*")
						.foregroundColor(.red)
				}
				
				Spacer()
			}
			.padding(.vertical, 8)
			.padding(.horizontal, 16)
			.background(colorScheme == .dark ? Color(.darkGray) : Color(.white))
			.cornerRadius(10)
			.shadow(color: .gray, radius: 1, x: 0, y: 5)
		}
		.buttonStyle(PlainButtonStyle())
	}
	
	private func checkAndDeleteStoreIfAllItemsBought(store: Store) {
		let allItemsBought = store.itemsArray.allSatisfy { $0.isBought }
		if allItemsBought {
			viewContext.delete(store)
			do {
				try viewContext.save()
			} catch {
				// handle the Core Data error
			}
		}
	}
}
