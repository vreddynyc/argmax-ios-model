import SwiftUI
import Kingfisher

@available(iOS 16.0, *)
struct ContentView: View {
        
    @StateObject private var viewModel = ViewModel()
    
    @State private var selectedIndex: Int = 0
    @State private var showDetailView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.userList.indices, id: \.self) { index in
                        let user = viewModel.userList[index]
                        
                        Text(user.display_name)
                            .font(.headline)
                        
                        KFImage(URL(string: user.profile_image))
                            .onSuccess { result in
                                viewModel.analyzeImage(index: index, profileImage: result.image)
                            }
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .onTapGesture {
                                selectedIndex = index
                                showDetailView = true
                            }
                        
                        Text((viewModel.modelResultMap[index] ?? []).first ?? "")
                            .foregroundColor(.green)
                        
                        Spacer()
                            .frame(height: 50)
                    }
                }.onAppear {
                    viewModel.getItems()
                }
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailView(index: selectedIndex).environmentObject(viewModel)
            }
        }
    }
}
