import UIKit
import LocalAuthentication

final class LoginViewController: UIViewController {

    // MARK: - Callback
    var onLoginSuccess: ((AppUser) -> Void)?
    private enum AuthMode {
        case login
        case register
    }

    private var authMode: AuthMode = .login

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let heroImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "AuthHero"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let l = UILabel()
        l.text = "BOAS VINDAS!"
        l.font = .appBold(22)
        l.textColor = .textPrimary
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Pronto para organizar suas finanças? Acesse agora"
        l.font = .appRegular(14)
        l.textColor = .textSecondary
        l.numberOfLines = 2
        return l
    }()

    private let nameField    = CustomTextField(placeholder: "Nome")
    private let emailField   = CustomTextField(placeholder: "E-mail", keyboardType: .emailAddress)
    private let passwordField = CustomTextField(placeholder: "Senha", isPassword: true)

    private let loginButton  = PrimaryButton(title: "Entrar")

    private let modeSwitchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .appSemiBold(14)
        btn.setTitleColor(.appButton, for: .normal)
        btn.contentHorizontalAlignment = .center
        return btn
    }()

    private let faceIDButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "faceid"), for: .normal)
        btn.tintColor = .appButton
        btn.isHidden = true
        return btn
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .white
        a.hidesWhenStopped = true
        return a
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        setupKeyboard()
        checkBiometricAvailability()
        updateMode(animated: false)
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        scrollView.addSubview(contentView)
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        contentView.addSubview(heroImageView)
        heroImageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            height: 360
        )

        // Labels
        contentView.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: heroImageView.bottomAnchor, leading: contentView.leadingAnchor,
                            paddingTop: 28, paddingLeading: 24)

        contentView.addSubview(subtitleLabel)
        subtitleLabel.anchor(top: welcomeLabel.bottomAnchor, leading: contentView.leadingAnchor,
                             trailing: contentView.trailingAnchor,
                             paddingTop: 8, paddingLeading: 24, paddingTrailing: 24)

        // Fields
        let fieldStack = UIStackView(arrangedSubviews: [nameField, emailField, passwordField])
        fieldStack.axis = .vertical
        fieldStack.spacing = 16

        contentView.addSubview(fieldStack)
        fieldStack.anchor(top: subtitleLabel.bottomAnchor, leading: contentView.leadingAnchor,
                          trailing: contentView.trailingAnchor,
                          paddingTop: 32, paddingLeading: 24, paddingTrailing: 24)

        // Face ID button
        contentView.addSubview(faceIDButton)
        faceIDButton.anchor(top: fieldStack.bottomAnchor, trailing: contentView.trailingAnchor,
                            paddingTop: 12, paddingTrailing: 24, width: 40, height: 40)

        // Login button
        contentView.addSubview(loginButton)
        loginButton.anchor(top: faceIDButton.bottomAnchor, leading: contentView.leadingAnchor,
                           trailing: contentView.trailingAnchor,
                           paddingTop: 16, paddingLeading: 24, paddingTrailing: 24)

        contentView.addSubview(modeSwitchButton)
        modeSwitchButton.anchor(top: loginButton.bottomAnchor, leading: contentView.leadingAnchor,
                                bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                                paddingTop: 18, paddingLeading: 24, paddingBottom: 40, paddingTrailing: 24,
                                height: 34)

        // Activity indicator inside login button
        loginButton.addSubview(activityIndicator)
        activityIndicator.centerIn(loginButton)

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        modeSwitchButton.addTarget(self, action: #selector(toggleAuthMode), for: .touchUpInside)
        faceIDButton.addTarget(self, action: #selector(faceIDTapped), for: .touchUpInside)
    }

    private func checkBiometricAvailability() {
        let service = BiometricService.shared
        if service.isBiometricAvailable && AppUser.loadLocally() != nil {
            faceIDButton.isHidden = false
        }
    }

    // MARK: - Actions
    @objc private func loginTapped() {
        switch authMode {
        case .login:
            login()
        case .register:
            register()
        }
    }

    private func login() {
        let email    = emailField.text.trimmingCharacters(in: .whitespaces)
        let password = passwordField.text

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Atenção", message: "Preencha e-mail e senha.")
            return
        }

        setLoading(true)
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            self?.setLoading(false)
            switch result {
            case .success(let user):
                self?.onLoginSuccess?(user)
            case .failure(let error):
                self?.showAlert(title: "Erro", message: error.localizedDescription)
            }
        }
    }

    private func register() {
        let name = nameField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text

        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Atenção", message: "Preencha nome, e-mail e senha.")
            return
        }

        guard password.count >= 6 else {
            showAlert(title: "Senha curta", message: "Use uma senha com pelo menos 6 caracteres.")
            return
        }

        setLoading(true)
        AuthService.shared.register(name: name, email: email, password: password) { [weak self] result in
            self?.setLoading(false)
            switch result {
            case .success(let user):
                self?.onLoginSuccess?(user)
            case .failure(let error):
                self?.showAlert(title: "Erro ao criar conta", message: error.localizedDescription)
            }
        }
    }

    @objc private func toggleAuthMode() {
        authMode = authMode == .login ? .register : .login
        updateMode(animated: true)
    }

    @objc private func faceIDTapped() {
        BiometricService.shared.authenticate { [weak self] success, error in
            if success, let user = AppUser.loadLocally() {
                self?.onLoginSuccess?(user)
            } else if let error = error {
                self?.showAlert(title: "Face ID", message: error.localizedDescription)
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        loginButton.setTitle(loading ? "" : primaryButtonTitle, for: .normal)
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        loginButton.isEnabled = !loading
        modeSwitchButton.isEnabled = !loading
        faceIDButton.isEnabled = !loading
    }

    private var primaryButtonTitle: String {
        authMode == .login ? "Entrar" : "Criar conta"
    }

    private func updateMode(animated: Bool) {
        let changes = {
            self.welcomeLabel.text = self.authMode == .login ? "BOAS VINDAS!" : "CRIAR CONTA"
            self.subtitleLabel.text = self.authMode == .login
                ? "Pronto para organizar suas finanças? Acesse agora"
                : "Comece agora a organizar suas finanças"
            self.loginButton.setTitle(self.primaryButtonTitle, for: .normal)
            self.modeSwitchButton.setTitle(
                self.authMode == .login ? "Ainda não tem conta? Criar conta" : "Já tenho conta",
                for: .normal
            )
            self.nameField.alpha = self.authMode == .login ? 0 : 1
            self.nameField.isHidden = self.authMode == .login
            self.faceIDButton.alpha = self.authMode == .login ? 1 : 0
            self.faceIDButton.isUserInteractionEnabled = self.authMode == .login
            self.view.layoutIfNeeded()
        }

        animated ? UIView.animate(withDuration: 0.2, animations: changes) : changes()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Keyboard
    private func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
}
