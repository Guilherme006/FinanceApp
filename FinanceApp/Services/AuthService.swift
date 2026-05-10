import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()
    private init() {}

    var currentUserID: String? { Auth.auth().currentUser?.uid }
    var isLoggedIn: Bool { Auth.auth().currentUser != nil }

    // MARK: - Register
    func register(
        name: String,
        email: String,
        password: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = result?.user.uid else { return }

            let user = AppUser(uid: uid, name: name, email: email, photoURL: nil)
            Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(["uid": uid, "name": name, "email": email]) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        user.saveLocally()
                        completion(.success(user))
                    }
                }
        }
    }

    // MARK: - Login
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let uid = result?.user.uid else { return }

            Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument { snapshot, err in
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard
                        let data = snapshot?.data(),
                        let name = data["name"] as? String,
                        let email = data["email"] as? String
                    else {
                        completion(.failure(NSError(domain: "AuthService", code: -1,
                                                    userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado."])))
                        return
                    }
                    let photoURL = data["photoURL"] as? String
                    let user = AppUser(uid: uid, name: name, email: email, photoURL: photoURL)
                    user.saveLocally()
                    completion(.success(user))
                }
        }
    }

    // MARK: - Logout
    func logout() throws {
        try Auth.auth().signOut()
        AppUser.removeLocally()
    }

    // MARK: - Update photo URL in Firestore
    func updatePhotoURL(_ url: String, completion: @escaping (Error?) -> Void) {
        guard let uid = currentUserID else { return }
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData(["photoURL": url], completion: completion)
    }
}
