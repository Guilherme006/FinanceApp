import Foundation

struct AppUser: Codable {
    let uid: String
    var name: String
    var email: String
    var photoURL: String?

    enum CodingKeys: String, CodingKey {
        case uid, name, email, photoURL
    }
}

// MARK: - Local persistence
extension AppUser {
    static let storageKey = "saved_user"

    func saveLocally() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppUser.storageKey)
        }
    }

    static func loadLocally() -> AppUser? {
        guard let data = UserDefaults.standard.data(forKey: AppUser.storageKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else { return nil }
        return user
    }

    static func removeLocally() {
        UserDefaults.standard.removeObject(forKey: AppUser.storageKey)
    }
}
