import SwiftUI

struct DetailView: View {
    
    var selectedIndex: Int
    
    init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
    
    var body: some View {
        let defaults = UserDefaults.standard
        if let modelDataText = defaults.string(forKey: "key" + String(selectedIndex)) {
            Text(modelDataText)
        }
    }
}
