import UIKit

final class BudgetCell: UITableViewCell {

    static let identifier = "BudgetCell"

    private let calendarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = .textSecondary
        iv.contentMode = .scaleAspectFit
        iv.anchor(width: 18, height: 18)
        return iv
    }()

    private let monthLabel: UILabel = {
        let l = UILabel()
        l.font = .appMedium(15)
        l.textColor = .textSecondary
        return l
    }()

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .appBold(15)
        l.textColor = .textPrimary
        l.textAlignment = .right
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        let leftStack = UIStackView(arrangedSubviews: [calendarIcon, monthLabel])
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [leftStack, amountLabel, deleteButton])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
        mainStack.alignment = .center

        contentView.addSubview(mainStack)
        mainStack.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 12, paddingLeading: 16, paddingBottom: 12, paddingTrailing: 16
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

    func configure(with budget: Budget) {
        monthLabel.text  = budget.displayLabel
        amountLabel.text = budget.limit.brlFormatted
    }
}
