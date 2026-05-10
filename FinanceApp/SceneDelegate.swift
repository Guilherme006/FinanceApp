import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)

        coordinator = AppCoordinator(navigationController: navController)
        coordinator?.start()

        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
