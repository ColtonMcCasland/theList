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
    @State private var isKeyboardShowing = false

    @State private var slideOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0

    var body: some View {
        VStack {
            if stores.isEmpty || stores.contains(where: { ($0.items as? Set<GroceryItem>)?.isEmpty ?? true }) {
                VStack {
                    Text("The list is empty. Add stores and items.")
                        .foregroundColor(.gray)
                        .padding()
                }
            } else {
                List {
                    ForEach(stores, id: \.self) { store in
                        StoreView(store: store, isAddItemAndStoreVisible: $isAddItemAndStoreVisible, selectedStore: $selectedStore)
                    }
                }
                .transition(.opacity) // Add a fade-in transition for the list of stores
            }

            Spacer() // Add spacer to push the ZStack to the bottom

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
                .frame(maxWidth: .infinity) // Ensure VStack takes the full width
                .frame(height: isAddItemAndStoreVisible ? 300 : 100) // Increase the bottom height here
                .padding(.bottom, isAddItemAndStoreVisible ? 100 : 15) // Additional padding to extend past the screen when visible
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Add the corner radius here
                .shadow(radius: 5) // Optionally, you can add a shadow for a visual effect
                .offset(y: slideOffset) // Apply the offset to the sliding view

                Button(action: {
                    withAnimation(.spring()) {
                        self.isAddItemAndStoreVisible.toggle()
                        if !isAddItemAndStoreVisible {
                            self.newItemName = ""
                            self.newStoreName = ""
                            self.selectedStore = nil
                            if isKeyboardShowing {
                                dismissKeyboard()
                            }
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
                .alignmentGuide(.top) { d in d[.bottom] - 50 }
                .offset(y: slideOffset) // Apply the offset to the sliding view
                .gesture(DragGesture() // Add DragGesture to the chevron
                    .onChanged { gesture in
                        // Calculate the offset based on the drag
                        let offsetY = gesture.translation.height
                        if offsetY > 0 {
                            slideOffset = offsetY
                        }
                    }
                    .onEnded { gesture in
                        // Determine whether to close or open the sliding view based on the drag distance
                        let offsetY = gesture.translation.height
                        if offsetY > 100 {
                            isAddItemAndStoreVisible = false
                        } else {
                            isAddItemAndStoreVisible = true
                        }
                        withAnimation(.spring()) {
                            slideOffset = 0
                        }
                    }
                )
                .gesture(TapGesture() // Add TapGesture to the chevron
                    .onEnded {
                        withAnimation(.spring()) {
                            self.isAddItemAndStoreVisible.toggle()
                            if !isAddItemAndStoreVisible {
                                self.newItemName = ""
                                self.newStoreName = ""
                                self.selectedStore = nil
                                if isKeyboardShowing {
                                    dismissKeyboard()
                                }
                            }
                        }
                    }
                )
            }
            .frame(height: isAddItemAndStoreVisible ? 300 : 50) // Increase the height of the sliding view
            .animation(.spring(), value: isAddItemAndStoreVisible)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isKeyboardShowing = true
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isKeyboardShowing = false
                }
            }
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
                ActionSheet(title: Text("Settings"), buttons: [
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

#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
