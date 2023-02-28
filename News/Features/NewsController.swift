import SafariServices
import UIKit

class NewsController: KNController {
    var suggestKeywords = ["Today", "Weather", "Technology"]
    override var shouldGetDataViewDidLoad: Bool { true }
    lazy var tableView = UITableView(cells: [NewsCell.self], source: self)
    var datasource = [News]() {
        didSet {
            tableView.reloadData()
        }
    }

    let searchBar = UISearchBar()
    lazy var currentKeyword: String = suggestKeywords.randomElement()!
    var newsLoader = PaginationLoad()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc override func getData() {
        getNews(keyword: currentKeyword)
    }
    
    func getNews(keyword: String) {
        newsLoader.execute { [weak self] in
            guard let self = self else { return }
            
            GetNewsWorker(keyword: keyword, page: self.newsLoader.page)
                .execute(onSuccess: { news in
                    if self.newsLoader.page == 1 {
                        self.datasource = news
                    } else {
                        self.datasource.append(contentsOf: news)
                    }
                    self.newsLoader.finish(result: news)
                    
                }, onFailure: { message in
                    Messenger.showMessage(message, title: "Oops")
                })
        }
    }

    override func setupView() {
        searchBar.placeholder = "Search anything..."
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        view.addSubviews(views: searchBar)
        searchBar.horizontalSuperview()
        searchBar.topToSuperviewSafeArea()
        
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .singleLine
        tableView.separatorInset.right = 16
        view.addSubviews(views: tableView)
        tableView.horizontalSuperview()
        tableView.verticalSpacing(toView: searchBar, space: 16)
        tableView.bottomToSuperviewSafeArea()
    }
}

extension NewsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCell = tableView.dequeue(at: indexPath)
        cell.setData(datasource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = datasource[indexPath.row].url, let url = URL(string: urlString) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isReachingEnd = scrollView.contentOffset.y >= 0
        && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        if isReachingEnd {
            getData()
        }
    }
}

extension NewsController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let newText = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text) {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            perform(#selector(onSearch), with: newText, afterDelay: 0.5)
        }

        return true
    }
    
    @objc func onSearch(keyword: String) {
        if keyword.isEmpty { return }
        currentKeyword = keyword
        newsLoader.reset()
        getNews(keyword: keyword)
    }
}

class NewsCell: KNTableCell {
    let titleLabel = UILabel(
        font: .systemFont(ofSize: 16),
        color: .black, numberOfLines: 2)
    let headlineLabel  = UILabel(
        font: .systemFont(ofSize: 13),
        color: .lightGray, numberOfLines: 2)
    let thumbnailImageView = UIImageView(background: .lightGray)
    
    override func setupView() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.setCorner(radius: 5)
        contentView.addSubviews(views: thumbnailImageView)
        thumbnailImageView.leftToSuperview(space: 16)
        thumbnailImageView.centerYToSuperview()
        thumbnailImageView.size(width: 80, height: 60)
        
        let textStack = UIStackView(axis: .vertical, distributon: .fill, alignment: .fill, space: 4)
        textStack.addViews(titleLabel, headlineLabel)
        contentView.addSubviews(views: textStack)
        textStack.leftHorizontalSpacing(toView: thumbnailImageView, space: 16)
        textStack.rightToSuperview(space: -16)
        textStack.verticalSuperview(space: 16)
    }
    
    func setData(_ data: News) {
        titleLabel.text = data.title
        headlineLabel.text = data.description
        thumbnailImageView.freshDownload(from: data.imageUrl)
    }
}
