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
                        Text(user.display_name.capitalized)
                            .font(.headline)
                        VStack {
                            HStack {
                                KFImage(URL(string: user.profile_image))
                                    .onSuccess { result in
                                        viewModel.analyzeImage(index: index, profileImage: result.image)
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                Spacer()
                                    .frame(width: 20)
                                Text((viewModel.modelResultMap[index] ?? []).first ?? "")
                                    .foregroundColor(.green)
                            }
                        }.onTapGesture {
                            selectedIndex = index
                            showDetailView = true
                        }
                        Spacer()
                            .frame(height: 50)
                    }
                }.onAppear {
                    viewModel.getUsers()
                }
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailView(index: selectedIndex).environmentObject(viewModel)
            }
        }
    }
}
