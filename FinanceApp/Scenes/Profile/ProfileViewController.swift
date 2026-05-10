import UIKit

final class ProfileViewController: UIViewController {

    var onBack: (() -> Void)?
    var onLogout: (() -> Void)?

    // MARK: - UI
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .textPrimary
        return btn
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Perfil"
        l.font = .appBold(20)
        l.textColor = .textPrimary
        return l
    }()

    private let avatarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        btn.tintColor = .textSecondary
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 104, weight: .regular), forImageIn: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 60
        btn.anchor(width: 120, height: 120)
        return btn
    }()

    private let editPhotoLabel: UILabel = {
        let l = UILabel()
        l.text = "Alterar foto"
        l.font = .appMedium(14)
        l.textColor = .appPrimary
        l.textAlignment = .center
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .appBold(20)
        l.textColor = .textPrimary
        l.textAlignment = .center
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .appRegular(14)
        l.textColor = .textSecondary
        l.textAlignment = .center
        return l
    }()

    private let logoutButton = PrimaryButton(title: "Sair da conta")

    private var user: AppUser?
    private var profileImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        loadUser()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                          paddingTop: 8, paddingLeading: 8, width: 40, height: 40)

        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(avatarButton)
        avatarButton.anchor(top: titleLabel.bottomAnchor, paddingTop: 32)
        avatarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(editPhotoLabel)
        editPhotoLabel.anchor(top: avatarButton.bottomAnchor, paddingTop: 8)
        editPhotoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(nameLabel)
        nameLabel.anchor(top: editPhotoLabel.bottomAnchor, leading: view.leadingAnchor,
                         trailing: view.trailingAnchor, paddingTop: 24, paddingLeading: 24, paddingTrailing: 24)

        view.addSubview(emailLabel)
        emailLabel.anchor(top: nameLabel.bottomAnchor, leading: view.leadingAnchor,
                          trailing: view.trailingAnchor, paddingTop: 8, paddingLeading: 24, paddingTrailing: 24)

        view.addSubview(logoutButton)
        logoutButton.anchor(leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            trailing: view.trailingAnchor,
                            paddingLeading: 24, paddingBottom: 24, paddingTrailing: 24)
        logoutButton.backgroundColor = UIColor.expenseRed.withAlphaComponent(0.15)
        logoutButton.setTitleColor(.expenseRed, for: .normal)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)

        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        editPhotoLabel.isUserInteractionEnabled = true
        editPhotoLabel.addGestureRecognizer(tapLabel)

        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func loadUser() {
        user = AppUser.loadLocally()
        nameLabel.text  = user?.name
        emailLabel.text = user?.email

        if let urlString = user?.photoURL, let url = URL(string: urlString) {
            loadRemoteImage(from: url)
        }
    }

    private func loadRemoteImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImage = image
                self?.setAvatarImage(image)
            }
        }.resume()
    }

    private func setAvatarImage(_ image: UIImage) {
        avatarButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        avatarButton.imageView?.layer.cornerRadius = 60
        avatarButton.imageView?.clipsToBounds = true
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        onBack?()
    }

    @objc private func changePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Sair", message: "Deseja fazer logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive) { [weak self] _ in
            self?.onLogout?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerController
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let image = image else { return }
        setAvatarImage(image)

        StorageService.shared.uploadProfilePhoto(image) { [weak self] result in
            switch result {
            case .success(let url):
                AuthService.shared.updatePhotoURL(url) { _ in
                    var updated = AppUser.loadLocally()
                    updated?.photoURL = url
                    // rebuild and save
                    if var u = self?.user {
                        u = AppUser(uid: u.uid, name: u.name, email: u.email, photoURL: url)
                        u.saveLocally()
                    }
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
