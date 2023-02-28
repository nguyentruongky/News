import Foundation

class AppData {
    static var histories: [String] {
        get {
            let value = UserDefaults.standard.string(forKey: "searchHistories")
            return value?.components(separatedBy: "-|-") ?? []
        }

        set {
            UserDefaults.standard.setValue(newValue.joined(separator: "-|-"), forKey: "searchHistories")
        }
    }
}
