import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Callback
    var onFinished: (() -> Void)?

    // MARK: - UI
    private let logoContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .appPrimary
        // Using SF Symbol as placeholder; replace with your actual logo asset
        iv.image = UIImage(systemName: "creditcard.fill")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let primaryShape: UIView = {
        let v = UIView()
        v.backgroundColor = .appPrimary
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let secondaryShape: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.4)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(logoContainerView)
        logoContainerView.centerIn(view)
        NSLayoutConstraint.activate([
            logoContainerView.widthAnchor.constraint(equalToConstant: 120),
            logoContainerView.heightAnchor.constraint(equalToConstant: 120)
        ])

        // Two overlapping rhombus shapes (like the Figma logo)
        logoContainerView.addSubview(secondaryShape)
        logoContainerView.addSubview(primaryShape)

        NSLayoutConstraint.activate([
            primaryShape.widthAnchor.constraint(equalToConstant: 60),
            primaryShape.heightAnchor.constraint(equalToConstant: 60),
            primaryShape.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor, constant: -10),
            primaryShape.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor, constant: -10),

            secondaryShape.widthAnchor.constraint(equalToConstant: 60),
            secondaryShape.heightAnchor.constraint(equalToConstant: 60),
            secondaryShape.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor, constant: 10),
            secondaryShape.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor, constant: 10)
        ])

        primaryShape.transform = CGAffineTransform(rotationAngle: .pi / 6)
        secondaryShape.transform = CGAffineTransform(rotationAngle: .pi / 6)

        // Initial state for animation
        logoContainerView.alpha = 0
        logoContainerView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    }

    // MARK: - Animation
    private func runAnimation() {
        // Phase 1: Logo appears with spring animation
        UIView.animate(
            withDuration: 0.8,
            delay: 0.2,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.logoContainerView.alpha = 1
                self.logoContainerView.transform = .identity
            }
        ) { _ in
            // Phase 2: Subtle pulse
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [.autoreverse]) {
                self.logoContainerView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            } completion: { _ in
                self.logoContainerView.transform = .identity
                // Phase 3: Fade out and transition
                UIView.animate(withDuration: 0.5, delay: 0.4) {
                    self.logoContainerView.alpha = 0
                    self.view.alpha = 0
                } completion: { _ in
                    self.onFinished?()
                }
            }
        }
    }
}
