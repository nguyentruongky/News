import UIKit

class PaginationLoad: NSObject {
    var page = 1
    var canLoadMore = true
    var isLoading = false

    func execute(action: @escaping() -> Void) {
        guard !isLoading else { return }
        guard canLoadMore else { return }
        isLoading = true
        action()
    }

    func finish(result: [Any]) {
        isLoading = false
        page += 1
        canLoadMore = !result.isEmpty
    }
    
    func reset() {
        page = 1
        canLoadMore = true
        isLoading = false
    }
}
