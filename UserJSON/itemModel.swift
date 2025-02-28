import SwiftUI

struct Item: Codable, Identifiable {
    let id = UUID()
    let account_id : Int
    let display_name: String
    let profile_image: String
}
