import SwiftUI

struct ListView: View {
	@State private var showingAddItemView = false
	
	var body: some View {
		ZStack {
			NavigationView {
				VStack {
					// Example list item
					Text("No Items")
				}
				.navigationBarTitle("Items", displayMode: .inline)
				.navigationBarItems(trailing:
											Button(action: {
					withAnimation {
						self.showingAddItemView.toggle()
					}
				}) {
					Image(systemName: "plus")
				}
				)
			}
			
			if showingAddItemView {
				AddItemView(showingAddItemView: $showingAddItemView)
					.transition(.move(edge: .bottom))
			}
		}
	}
}


struct ListView_Previews: PreviewProvider {
	static var previews: some View {
		ListView()
	}
}
