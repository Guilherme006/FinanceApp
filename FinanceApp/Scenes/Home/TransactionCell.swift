import UIKit

final class TransactionCell: UITableViewCell {

    static let identifier = "TransactionCell"

    // MARK: - UI
    private let iconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.15)
        v.layer.cornerRadius = 22
        v.anchor(width: 44, height: 44)
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .appPrimary
        iv.anchor(width: 22, height: 22)
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .appMedium(15)
        l.textColor = .textPrimary
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .appRegular(12)
        l.textColor = .textSecondary
        return l
    }()

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .appSemiBold(15)
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .appPrimary
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .regular), forImageIn: .normal)
        btn.anchor(width: 24, height: 24)
        return btn
    }()

    var onDeleteTapped: (() -> Void)?

    private let deleteThreshold: CGFloat = 80
    private var didTriggerDelete = false

    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        return gesture
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        iconContainer.addSubview(iconImageView)
        iconImageView.centerIn(iconContainer)

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        amountLabel.anchor(width: 118)

        let mainStack = UIStackView(arrangedSubviews: [iconContainer, labelStack, amountLabel, deleteButton])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
        mainStack.alignment = .center

        contentView.addSubview(mainStack)
        mainStack.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 10, paddingLeading: 16, paddingBottom: 10, paddingTrailing: 16
        )

        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        contentView.addGestureRecognizer(panGesture)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onDeleteTapped = nil
        resetSwipe(animated: false)
    }

    @objc private func deleteTapped() { onDeleteTapped?() }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !didTriggerDelete else { return }

        let translation = gesture.translation(in: contentView)
        switch gesture.state {
        case .changed:
            let offset = max(-deleteThreshold, min(0, translation.x))
            contentView.transform = CGAffineTransform(translationX: offset, y: 0)
        case .ended:
            translation.x <= -deleteThreshold ? triggerSwipeDelete() : resetSwipe(animated: true)
        case .cancelled, .failed:
            resetSwipe(animated: true)
        default:
            break
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGesture else { return true }
        let velocity = panGesture.velocity(in: contentView)
        return abs(velocity.x) > abs(velocity.y) && velocity.x < 0
    }

    private func triggerSwipeDelete() {
        didTriggerDelete = true
        UIView.animate(withDuration: 0.16, animations: {
            self.contentView.transform = CGAffineTransform(translationX: -self.deleteThreshold, y: 0)
            self.contentView.alpha = 0.65
        }, completion: { _ in
            self.onDeleteTapped?()
            self.resetSwipe(animated: true)
        })
    }

    private func resetSwipe(animated: Bool) {
        didTriggerDelete = false
        let changes = {
            self.contentView.transform = .identity
            self.contentView.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: changes)
        } else {
            changes()
        }
    }

    // MARK: - Configure
    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.title
        dateLabel.text  = transaction.date.shortFormatted
        amountLabel.text = transaction.amount.brlFormatted

        let icon = UIImage(systemName: transaction.category.iconName) ?? UIImage(systemName: "tag")
        iconImageView.image = icon

        if transaction.isIncome {
            amountLabel.textColor = .incomeGreen
        } else {
            amountLabel.textColor = .expenseRed
        }
    }
}
