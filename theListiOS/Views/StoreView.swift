import SwiftUI

struct StoreView: View {
	@Environment(\.managedObjectContext) private var viewContext
	let store: Store
	@Binding var isAddItemAndStoreVisible: Bool
	@Binding var selectedStore: Store?
	
	var body: some View {
		VStack {
			HStack {
				Text(store.name ?? "Unspecified")
					.font(.title)
					.fontWeight(.bold)
					.padding()
					.background(Color.blue.opacity(0.2))
					.cornerRadius(10)
					.onTapGesture {
						selectedStore = store
						isAddItemAndStoreVisible = true
					}
				Spacer()
			}
			.padding(.horizontal)
			
			ForEach(store.itemsArray, id: \.self) { item in
				HStack {
					ItemView(item: item)
					Spacer()
				}
				.padding(.horizontal)
				.onTapGesture {
					item.isBought.toggle()
					do {
						try viewContext.save()
					} catch {
						// handle the Core Data error
					}
					checkAndDeleteStoreIfAllItemsBought(store: store)
				}
			}
		}
		.padding(.vertical)
		.background(Color.white)
		.cornerRadius(10)
		.shadow(color: .gray, radius: 5, x: 0, y: 0)
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
