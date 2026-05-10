import UIKit

final class AppCoordinator {

    private let navigationController: UINavigationController
    private weak var homeViewController: HomeViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showSplash()
    }

    // MARK: - Splash
    private func showSplash() {
        let splash = SplashViewController()
        splash.onFinished = { [weak self] in
            if AuthService.shared.isLoggedIn && AppUser.loadLocally() != nil {
                self?.showHome()
            } else {
                self?.showLogin()
            }
        }
        navigationController.setViewControllers([splash], animated: false)
    }

    // MARK: - Login
    private func showLogin() {
        let login = LoginViewController()
        login.onLoginSuccess = { [weak self] _ in
            NotificationService.shared.requestAuthorization { granted in
                if granted { NotificationService.shared.scheduleDailyTransactionReminder() }
            }
            self?.showHome()
        }
        navigationController.setViewControllers([login], animated: true)
    }

    // MARK: - Home
    private func showHome() {
        let home = HomeViewController()
        homeViewController = home

        home.onAddTransaction = { [weak self, weak home] date in
            self?.showNewTransaction(for: date) {
                home?.reloadData()
            }
        }
        home.onOpenBudgets = { [weak self, weak home] in
            self?.showBudgets { home?.reloadData() }
        }
        home.onOpenProfile = { [weak self] in
            self?.showProfile()
        }
        home.onLogout = { [weak self] in
            self?.logoutAndShowLogin()
        }

        navigationController.setViewControllers([home], animated: true)
    }

    // MARK: - New Transaction
    private func showNewTransaction(for date: Date, onDismiss: @escaping () -> Void) {
        let newTx = NewTransactionViewController()
        newTx.initialDate = date
        newTx.modalPresentationStyle = .overCurrentContext
        newTx.modalTransitionStyle   = .coverVertical
        newTx.onDismiss = onDismiss
        navigationController.present(newTx, animated: true)
    }

    // MARK: - Budgets
    private func showBudgets(onDismiss: @escaping () -> Void) {
        let budget = BudgetViewController()
        budget.onDismiss = onDismiss
        navigationController.pushViewController(budget, animated: true)
    }

    // MARK: - Profile
    private func showProfile() {
        let profile = ProfileViewController()
        profile.onLogout = { [weak self] in
            self?.logoutAndShowLogin()
        }
        navigationController.pushViewController(profile, animated: true)
    }

    private func logoutAndShowLogin() {
        try? AuthService.shared.logout()
        NotificationService.shared.cancelAllNotifications()
        showLogin()
    }
}
