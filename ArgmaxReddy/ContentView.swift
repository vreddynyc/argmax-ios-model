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
                                print("Image loaded successfully: \(result.cacheType)")
                                viewModel.analyzeImage(index: index, profileImage: result.image)
                            }
                            .onFailure { error in
                                print("Image failed to load: \(error.localizedDescription)")
                            }
                            .onProgress { receivedSize, totalSize in
                                print("Loading progress: \(receivedSize)/\(totalSize)")
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
