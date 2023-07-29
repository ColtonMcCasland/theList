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

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(stores, id: \.self) { store in
                        StoreView(store: store)
                    }
                }

                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        VStack {
                            TextField("New item name", text: $newItemName)
                                .padding()
                                .opacity(isAddItemAndStoreVisible ? 1 : 0)
                            TextField("New store name", text: $newStoreName)
                                .padding()
                                .opacity(isAddItemAndStoreVisible ? 1 : 0)
                            Button("Add Item and Store") {
                                // Implement the logic to add the item and store to the CoreData context (if needed)
                                newItemName = ""
                                newStoreName = ""
                            }
                            .disabled(newItemName.isEmpty || newStoreName.isEmpty) // Change the condition here
                            .padding()
                        }
                        .transition(.move(edge: .bottom))

                        Button(action: {
                            withAnimation(.spring()) {
                                self.isAddItemAndStoreVisible.toggle()
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
                        .offset(y: isAddItemAndStoreVisible ? geometry.size.height - 30 : 0)
                    }
                }
                .frame(height: isAddItemAndStoreVisible ? 200 : 50)
                .animation(.spring(), value: isAddItemAndStoreVisible)
            }
            .id(refresh)
        }
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
                        // Implement the logic to log out the user (if needed)
                        showingActionSheet = false
                    }),
                    .cancel()
                ])
            }
        )
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
