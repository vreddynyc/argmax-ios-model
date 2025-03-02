import SwiftUI
import Kingfisher

struct DetailView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    private let index: Int
    
    init(index: Int) {
        self.index = index
    }
            
    var body: some View {
        
        let item = viewModel.userList[index]
        
        Text(item.display_name)
            .font(.headline)
        
        KFImage(URL(string: item.profile_image))
            .onSuccess { result in
                print("Image loaded successfully: \(result.cacheType)")
            }
            .onFailure { error in
                print("Image failed to load: \(error.localizedDescription)")
            }
            .onProgress { receivedSize, totalSize in
                print("Loading progress: \(receivedSize)/\(totalSize)")
            }
            .resizable()
            .scaledToFit()
            .frame(width: 220, height: 220)
        
        Text((viewModel.modelResultMap[index] ?? [])[1])
    }
}
