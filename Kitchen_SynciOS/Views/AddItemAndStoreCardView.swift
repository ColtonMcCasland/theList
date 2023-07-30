import SwiftUI
import CoreData

struct AddItemAndStoreCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.name, ascending: true)],
        animation: .default)
    private var stores: FetchedResults<Store>

    @Binding var newItemName: String
    @Binding var newStoreName: String
    @Binding var isAddItemAndStoreVisible: Bool
    @Binding var selectedStore: Store?
    @Binding var refresh: Bool
    @Binding var isKeyboardShowing: Bool
    @State private var slideOffset: CGFloat = 0.0

    var body: some View {
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
                    if isKeyboardShowing {
                        dismissKeyboard()
                    }
                }
                .opacity(isAddItemAndStoreVisible ? 1 : 0)
                .disabled(newItemName.isEmpty || (newStoreName.isEmpty && selectedStore == nil))
                .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: isAddItemAndStoreVisible ? 300 : 100)
            .padding(.bottom, isAddItemAndStoreVisible ? 100 : 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 5)
            .offset(y: slideOffset)

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
                    .scaleEffect(isAddItemAndStoreVisible ? 1.3 : 1.0)
            }
            .padding()
            .background(Color.white)
            .clipShape(Circle())
            .alignmentGuide(.top) { d in d[.bottom] - 50 }
            .offset(y: slideOffset)
            .gesture(DragGesture()
                .onChanged { gesture in
                    let offsetY = gesture.translation.height
                    if offsetY > 0 {
                        slideOffset = offsetY
                    }
                }
                .onEnded { gesture in
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
            .gesture(TapGesture()
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
        .frame(height: isAddItemAndStoreVisible ? 300 : 50)
        .animation(.spring(), value: isAddItemAndStoreVisible)
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
