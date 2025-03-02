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
            .resizable()
            .scaledToFit()
            .frame(width: 220, height: 220)
        
        Text((viewModel.modelResultMap[index] ?? [])[1])
    }
}
