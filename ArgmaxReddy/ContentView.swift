import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
        
    @State private var itemList: ItemList = ItemList(items: [])
    @State private var showDetailView = false
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(itemList.items.indices, id: \.self) { index in
                        let item = itemList.items[index]
                        Text(item.display_name)
                            .font(.headline)
                        ImageView(item: item, index: index)
                            .onTapGesture {
                                selectedIndex = index
                                showDetailView = true
                            }
                        Spacer()
                            .frame(height: 50)
                    }
                }.onAppear {
                    ViewModel().getItems { itemList in
                        self.itemList = itemList
                    }
                }
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailView(selectedIndex: selectedIndex)
            }
        }
    }
}
