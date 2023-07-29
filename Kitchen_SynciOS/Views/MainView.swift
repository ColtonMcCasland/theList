import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State private var showingActionSheet = false

    @State private var newItemName = ""
    @State private var newStoreName = ""
    
    @State private var refresh = false

    @State private var isAddItemAndStoreVisible = false
    @State private var selectedStore: Store?

    var body: some View {
        VStack {
            List {
                ForEach(stores, id: \.self) { store in
                    StoreView(store: store, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore)
                }
            }
            ZStack(alignment: .top) {
                VStack {
                    TextField("New item name", text: $newItemName)
                        .padding()
                        .opacity(isAddItemAndStoreVisible ? 1 : 0)
                    if selectedStore == nil {
                        TextField("New store name", text: $newStoreName)
                            .padding()
                            .opacity(isAddItemAndStoreVisible ? 1 : 0)
                    }
                    Button("Add Item") {
                        addItemAndStore(newItemName: newItemName, newStoreName: selectedStore?.name ?? newStoreName, stores: stores, viewContext: viewContext, refresh: $refresh)
                        newItemName = ""
                        newStoreName = ""
                        isAddItemAndStoreVisible = false
                        selectedStore = nil
                    }
                    .opacity(isAddItemAndStoreVisible ? 1 : 0)
                    .disabled(newItemName.isEmpty || (newStoreName.isEmpty && selectedStore == nil))
                    .padding()
                }
                .transition(.move(edge: .bottom))
                .frame(maxWidth: .infinity) // Ensure VStack takes the full width
                .frame(height: isAddItemAndStoreVisible ? 300 : 100) // Increase the bottom height here
                .padding(.bottom, isAddItemAndStoreVisible ? 100 : 15) // Additional padding to extend past the screen when visible
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Add the corner radius here
                .shadow(radius: 5) // Optionally, you can add a shadow for a visual effect

                Button(action: {
                    withAnimation(.spring()) {
                        self.isAddItemAndStoreVisible.toggle()
                        if !isAddItemAndStoreVisible {
                            self.newItemName = ""
                            self.newStoreName = ""
                            self.selectedStore = nil
                        }
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 80, height: 16)
                        .rotation3DEffect(isAddItemAndStoreVisible ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: 1, y: 0, z: 0))
                        .scaleEffect(isAddItemAndStoreVisible ? 1.3 : 1.0) // Adjusted scaleEffect value for increased bouncing
                    
                }
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .alignmentGuide(.top) { d in d[.bottom] - 70 } // Adjust the value (-70) to align the chevron as desired
            }
            .frame(height: isAddItemAndStoreVisible ? 300 : 50) // Increase the height of the sliding view
            .animation(.spring(), value: isAddItemAndStoreVisible)
        }
        .id(refresh)
        .navigationBarTitle("Grocery List", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Options"), buttons: [
                    .default(Text("Log Out"), action: {
                        isLoggedIn = false
                        showingActionSheet = false
                    }),
                    .cancel()
                ])
            }
        )
    }
}
