import UIKit
import FirebaseStorage
import FirebaseAuth

final class StorageService {

    static let shared = StorageService()
    private let storage = Storage.storage()
    private init() {}

    func uploadProfilePhoto(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let data = image.jpegData(compressionQuality: 0.6) else { return }

        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(data, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                completion(.success(urlString))
            }
        }
    }
}
