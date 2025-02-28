import SwiftUI

struct ContentView: View {
    
    @State private var itemList: ItemList = ItemList(items: [])
    @State private var showWelcomeView = false
        
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        if #available(iOS 16.0, *) {
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
                                    showWelcomeView = true
                                }
                            Spacer()
                                .frame(height: 50)
                        }
                    }.onAppear {
                        apiCall().getUsers { (itemList) in
                            self.itemList = itemList
                        }
                    }
                }
                .navigationDestination(isPresented: $showWelcomeView) {
                    DetailView(selectedIndex: selectedIndex)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
