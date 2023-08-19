import SwiftUI
import CoreData

struct ViewController: View {
	@Environment(\.managedObjectContext) private var viewContext
	@AppStorage("isLoggedIn") private var isLoggedIn = false
	@EnvironmentObject var appDelegate: AppDelegate
	
	@FetchRequest(
		entity: List.entity(),
		sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)],
		animation: .default)
	private var listNodes: FetchedResults<List>
	
	@State private var showingAddNodeView = false
	@State private var newNodeTitle = ""
	
	var body: some View {
		NavigationView {
			if isLoggedIn {
				StackedCardsView()
			} else {
				ICloudLoginView()
					.frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, minHeight: 200, idealHeight: 300, maxHeight: .infinity)
					.environment(\.managedObjectContext, viewContext)
			}
		}
	}
}
