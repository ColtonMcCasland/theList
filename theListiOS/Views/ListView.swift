import SwiftUI
import CoreData
import UniformTypeIdentifiers
import CloudKit

struct ListView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],animation: .default)
	private var stores: FetchedResults<Store>
	
	// Fetch request for the items with 'Required' priority
	@FetchRequest(entity: GroceryItem.entity(), sortDescriptors: [], predicate: NSPredicate(format: "priority == %@", "Required")) var requiredItems: FetchedResults<GroceryItem>
	@FetchRequest(entity: UserList.entity(), sortDescriptors: []) var userLists: FetchedResults<UserList>
	
	@AppStorage("isLoggedIn") private var isLoggedIn = true
	@State private var showingActionSheet = false
	
	@State private var newItemName = ""
	@State private var newStoreName = ""
	@State private var newItemPriority = "Optional"
	
	@State private var refresh = false
	@State private var isAddItemAndStoreVisible = false
	@State private var selectedStore: Store?
	@State private var isKeyboardShowing = false
	@State private var slideOffset: CGFloat = 0.0
	@State private var dragOffset: CGFloat = 0.0
	
	@State private var shareController: UICloudSharingController?

	
	var body: some View {
		VStack {
			if stores.isEmpty || stores.contains(where: { ($0.items as? Set<GroceryItem>)?.isEmpty ?? true }) {
				VStack {
					Text("The list is empty. Add stores and items.")
						.padding()
				}
			} else {
				let sortedStores = stores.sorted { store1, store2 in
					let requiredItemsCount1 = store1.itemsArray.filter { $0.priority == "Required" }.count
					let requiredItemsCount2 = store2.itemsArray.filter { $0.priority == "Required" }.count
					return requiredItemsCount1 > requiredItemsCount2
				}
				
				List {
					ForEach(sortedStores, id: \.self) { store in
						StoreView(store: store, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore)
					}
				}
				.listStyle(DefaultListStyle()) // Set the list style to PlainListStyle
				
			}
			
			Spacer() // Add spacer to push the ZStack to the bottom
			AddItemAndStoreView(newStoreName: $newStoreName, newItemName: $newItemName, newItemPriority: $newItemPriority, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore, refresh: $refresh, isKeyboardShowing: $isKeyboardShowing)
		}
		.id(refresh)
		.navigationBarTitle("theList.", displayMode: .inline)
		.navigationBarItems(trailing:
									Button(action: {
			showingActionSheet = true
		}) {
			Image(systemName: "ellipsis.circle")
				.resizable()
				.frame(width: 24, height: 24)
		}
			.actionSheet(isPresented: $showingActionSheet) {
				ActionSheet(title: Text("Settings"), buttons: [
					.default(Text("Log Out"), action: {
						isLoggedIn = false
						showingActionSheet = false
					}),
					.cancel()
				])
			}
		)
		.navigationBarItems(trailing: Button(action: { shareUserList(userList: userLists.first) }) {
			Image(systemName: "square.and.arrow.up")
		})
		.background( Color(.systemGroupedBackground))
	}
	
	func shareUserList(userList: UserList?) {
		guard let userListRecord = getCKRecordForUserList(userList: userList) else {
			print("Failed to get CKRecord for userList")
			return
		}
		
		let share = CKShare(rootRecord: userListRecord)
		share[CKShare.SystemFieldKey.title] = "Shared UserList" as CKRecordValue
		share.publicPermission = .readWrite
		
		let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [userListRecord, share], recordIDsToDelete: nil)
		modifyRecordsOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
			if let error = error {
				print("Failed to create share: \(error)")
			} else {
				print("Successfully created share")
			}
		}
		CKContainer.default().privateCloudDatabase.add(modifyRecordsOperation)
	}
	
	func getCKRecordForUserList(userList: UserList?) -> CKRecord? {
		if userList == nil {
			print("UserList is nil")
			return nil
		}
		
		let recordID = CKRecord.ID(recordName: "\(userList!.objectID)")
		let record = CKRecord(recordType: "UserList", recordID: recordID)
		
		// Set properties of the userList...
		// You'll need to decide how to represent the connected Store and GroceryItem entities in the CKRecord.
		
		return record
	}

}
