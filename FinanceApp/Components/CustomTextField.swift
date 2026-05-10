import UIKit

final class CustomTextField: UIView {

    // MARK: - UI Elements
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .appInput
        v.layer.cornerRadius = 8
        return v
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .textPrimary
        tf.font = .appRegular(16)
        tf.tintColor = .appPrimary
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()

    private var isPasswordField = false
    private var eyeButton: UIButton?

    // MARK: - Init
    init(placeholder: String, isPassword: Bool = false, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)
        self.isPasswordField = isPassword
        setup(placeholder: placeholder, isPassword: isPassword, keyboardType: keyboardType)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setup(placeholder: String, isPassword: Bool, keyboardType: UIKeyboardType) {
        addSubview(containerView)
        containerView.fillSuperview()
        containerView.addSubview(textField)

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.textSecondary.withAlphaComponent(0.75)]
        )
        textField.isSecureTextEntry = isPassword
        textField.keyboardType = keyboardType

        if isPassword {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            btn.setImage(UIImage(systemName: "eye"), for: .selected)
            btn.tintColor = UIColor.textSecondary.withAlphaComponent(0.95)
            btn.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
            containerView.addSubview(btn)
            btn.anchor(trailing: containerView.trailingAnchor, paddingTrailing: 16, width: 24, height: 24)
            btn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            textField.anchor(
                top: containerView.topAnchor,
                leading: containerView.leadingAnchor,
                bottom: containerView.bottomAnchor,
                trailing: btn.leadingAnchor,
                paddingTop: 16, paddingLeading: 16, paddingBottom: 16, paddingTrailing: 8
            )
            eyeButton = btn
        } else {
            textField.anchor(
                top: containerView.topAnchor,
                leading: containerView.leadingAnchor,
                bottom: containerView.bottomAnchor,
                trailing: containerView.trailingAnchor,
                paddingTop: 16, paddingLeading: 16, paddingBottom: 16, paddingTrailing: 16
            )
        }

        anchor(height: 54)
    }

    @objc private func togglePassword() {
        textField.isSecureTextEntry.toggle()
        eyeButton?.isSelected = !textField.isSecureTextEntry
    }

    var text: String { textField.text ?? "" }
}
