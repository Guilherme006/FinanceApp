import UIKit

final class PrimaryButton: UIButton {

    enum Style { case filled, outlined(color: UIColor) }

    private let style: Style

    init(title: String, style: Style = .filled) {
        self.style = style
        super.init(frame: .zero)
        configure(title: title)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func configure(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .appSemiBold(16)
        layer.cornerRadius = 12
        anchor(height: 54)

        switch style {
        case .filled:
            backgroundColor = .appButton
            setTitleColor(.white, for: .normal)
        case .outlined(let color):
            backgroundColor = .clear
            layer.borderWidth = 1.5
            layer.borderColor = color.cgColor
            setTitleColor(color, for: .normal)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                    : .identity
            }
        }
    }
}
