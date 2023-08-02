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
			.shadow(color: .gray, radius: 1, x: 0, y: 2)
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

// Now, let's create a custom sorting function to sort the items with 'Required' priority to the top.

extension ItemView {
	static func sortRequiredItemsFirst(_ items: FetchedResults<GroceryItem>) -> [GroceryItem] {
		let sortedItems = items.sorted {
			if $0.priority == "Required" && $1.priority != "Required" {
				return true
			} else if $0.priority != "Required" && $1.priority == "Required" {
				return false
			} else {
				// If both items have the same priority or both are not 'Required',
				// sort alphabetically by their name.
				return ($0.name ?? "") < ($1.name ?? "")
			}
		}
		return sortedItems
	}
}


