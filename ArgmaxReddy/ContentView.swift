import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
        
    @State private var itemList: ItemList = ItemList(items: [])
    @State private var showDetailView = false
    @State private var selectedIndex: Int = 0
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.userList.indices, id: \.self) { index in
                        let user = (viewModel.userList[index])
                        Text(user.display_name)
                            .font(.headline)
                        ImageView(item: user, index: index)
                            .onTapGesture {
                                selectedIndex = index
                                showDetailView = true
                            }
                        Spacer()
                            .frame(height: 50)
                    }
                }.onAppear {
                    viewModel.getItems()
                }
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailView(selectedIndex: selectedIndex)
            }
        }
    }
}
