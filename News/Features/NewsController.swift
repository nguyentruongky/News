import SafariServices
import UIKit

class NewsController: KNController {
    enum Mode {
        case searching, result
    }
    var displayMode = Mode.result {
        didSet {
            tableView.isHidden = displayMode == .searching
            if displayMode == .searching {
                getHistory()
            }
        }
    }

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
    var historyStack = UIStackView(axis: .vertical, distributon: .fill, alignment: .fill, space: 8)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    @objc override func getData() {
        getNews()
    }

    func getNews() {
        getNews(keyword: currentKeyword)
    }

    func getNews(keyword: String) {
        newsLoader.execute { [weak self] in
            guard let self = self else { return }

            GetNewsWorker(keyword: keyword, page: self.newsLoader.page)
                .execute(onSuccess: { news in
                    self.displayMode = .result

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

    func getHistory() {
        let historyButtons = AppData.histories.map { text -> UIButton in
            let button = UIButton()
            button.setTitle(text, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(onPressKeyword), for: .touchUpInside)
            return button
        }

        historyStack.clearView()
        historyStack.addViews(historyButtons)
    }

    @objc func onPressKeyword(button: UIButton) {
        searchBar.text = button.currentTitle
        if let keyword = button.currentTitle {
            onSearch(keyword: keyword)
        }
    }

    override func setupView() {
        searchBar.placeholder = "Search anything..."
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        view.addSubviews(views: searchBar)
        searchBar.horizontalSuperview()
        searchBar.topToSuperviewSafeArea()

        view.addSubviews(views: historyStack)
        historyStack.horizontalSuperview(space: 16)
        historyStack.verticalSpacing(toView: searchBar, space: 16)

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
            getNews()
        }
    }
}

extension NewsController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        displayMode = .result
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

        if !AppData.histories.contains(keyword) {
            AppData.histories.append(keyword)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        displayMode = .searching
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        displayMode = .result
    }
}
