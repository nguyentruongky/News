import Foundation

struct News {
    let author: String?
    let title: String
    let description: String
    let url: String?
    let imageUrl: String?
    let content: String
    
    init?(rawData: AnyObject) {
        guard let title = rawData["title"] as? String,
              let description = rawData["description"] as? String,
              let content = rawData["content"] as? String else {
            return nil
        }
        self.title = title
        self.description = description
        self.content = content
        
        author = rawData["author"] as? String
        url = rawData["url"] as? String
        imageUrl = rawData["urlToImage"] as? String
    }
}

struct GetNewsWorker {
    let keyword: String
    let page: Int
    
    func execute(onSuccess: @escaping([News]) -> Void, onFailure: @escaping(_ message: String) -> Void) {
        let api = "/everything?sortBy=popularity&apiKey=\(AppConfig.appId)&page=\(page)&pageSize=20&q=\(keyword)"
        ApiConnector.get(api, success: { response in
            guard let rawData = response["articles"] as? [AnyObject] else {
                onSuccess([])
                return
            }
            
            let news = rawData.compactMap { News(rawData: $0) }
            onSuccess(news)
        }, fail: { error in
            onFailure(error.displayMessage ?? "Something went wrong")
        })
    }
}
