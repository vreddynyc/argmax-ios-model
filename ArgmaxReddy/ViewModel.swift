import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    
    @Published var userList: [Item] = []
    
    func getItems() {
        guard let url = URL(string: "https://api.stackexchange.com/2.2/users?site=stackoverflow") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let itemList = try! JSONDecoder().decode(ItemList.self, from: data!)
            print(itemList)
            
            DispatchQueue.main.async {
                self.userList = itemList.items
            }
        }
        .resume()
    }
}
