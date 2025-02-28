import Foundation

class apiCall {
    func getUsers(completion:@escaping (ItemList) -> ()) {
        guard let url = URL(string: "https://api.stackexchange.com/2.2/users?site=stackoverflow") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let itemList = try! JSONDecoder().decode(ItemList.self, from: data!)
            print(itemList)
            
            DispatchQueue.main.async {
                completion(itemList)
            }
        }
        .resume()
    }
}
