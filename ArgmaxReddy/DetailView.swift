import SwiftUI
import Kingfisher

struct DetailView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    private let index: Int
    
    init(index: Int) {
        self.index = index
    }
            
    var body: some View {
        VStack {
            let item = viewModel.userList[index]
            Text(item.display_name.capitalized)
                .font(.headline)
            Spacer()
                .frame(height: 30)
            KFImage(URL(string: item.profile_image))
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            Spacer()
                .frame(height: 30)
            Text((viewModel.modelResultMap[index] ?? [])[1])
        }
    }
}
