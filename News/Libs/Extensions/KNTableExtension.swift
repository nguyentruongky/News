//  Created by Ky Nguyen

import UIKit

class KNTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    func setupView() { }
}

extension UITableView {
    convenience init(cells: [AnyClass], delegate: UITableViewDelegate? = nil, datasource: UITableViewDataSource? = nil) {
        self.init()
        for c in cells {
            register(c)
        }

        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        self.dataSource = datasource
        self.delegate = delegate
    }
    convenience init(cells: [AnyClass], source: UITableViewDelegate&UITableViewDataSource) {
        self.init()
        for c in cells {
            register(c)
        }

        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        dataSource = source
        delegate = source
    }
    func dequeue<T>(at indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
        return cell
    }
    func register(_ _class: AnyClass) {
        register(_class, forCellReuseIdentifier: String(describing: _class.self))
    }
}
