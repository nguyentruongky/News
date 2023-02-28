import UIKit
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
