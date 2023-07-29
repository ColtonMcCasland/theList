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
                                addItemAndStore(newItemName: newItemName, newStoreName: newStoreName, stores: stores, viewContext: viewContext, refresh: $refresh)
                                newItemName = ""
                                newStoreName = ""
                            }
                            .disabled(newItemName.isEmpty && newStoreName.isEmpty)
                            .padding()
                        }
                        .transition(.move(edge: .bottom))

                        Button(action: {
                            withAnimation {
                                self.isAddItemAndStoreVisible.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 80, height: 16)
                                .rotation3DEffect(isAddItemAndStoreVisible ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: 1, y: 0, z: 0))


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
                            logOut()
                            showingActionSheet = false
                        }),
                        .cancel()
                    ])
                }
            )
        }
        .navigationBarTitle("Grocery List", displayMode: .inline)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
