import UIKit

final class MonthSelectorCell: UICollectionViewCell {

    static let identifier = "MonthSelectorCell"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .appMedium(13)
        l.textAlignment = .center
        l.textColor = .textSecondary
        return l
    }()

    private let indicator: UIView = {
        let v = UIView()
        v.backgroundColor = .appPrimary
        v.layer.cornerRadius = 2
        v.isHidden = true
        return v
    }()

    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .textPrimary : .textSecondary
            label.font = isSelected ? .appBold(13) : .appMedium(13)
            indicator.isHidden = !isSelected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(indicator)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                     trailing: contentView.trailingAnchor)
        indicator.anchor(top: label.bottomAnchor, leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                         paddingTop: 4, height: 3)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with text: String) {
        label.text = text
    }
}
