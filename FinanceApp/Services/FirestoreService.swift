import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreService {

    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Transactions

    func addTransaction(_ transaction: Transaction, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("transactions").addDocument(from: transaction, completion: completion)
        } catch {
            completion(error)
        }
    }

    func fetchTransactions(
        for userID: String,
        month: Int,
        year: Int,
        completion: @escaping (Result<[Transaction], Error>) -> Void
    ) {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = 1
        guard
            let start = Calendar.current.date(from: comps),
            let end   = Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: start)
        else { return }

        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let items = snapshot?.documents.compactMap {
                    try? $0.data(as: Transaction.self)
                }
                .filter { transaction in
                    transaction.date >= start && transaction.date <= end
                }
                .sorted { $0.date > $1.date } ?? []
                completion(.success(items))
            }
    }

    func deleteTransaction(_ id: String, completion: @escaping (Error?) -> Void) {
        db.collection("transactions").document(id).delete(completion: completion)
    }

    // MARK: - Budgets

    func addBudget(_ budget: Budget, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("budgets").addDocument(from: budget, completion: completion)
        } catch {
            completion(error)
        }
    }

    func fetchBudgets(
        for userID: String,
        completion: @escaping (Result<[Budget], Error>) -> Void
    ) {
        db.collection("budgets")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                var budgets = snapshot?.documents.compactMap {
                    try? $0.data(as: Budget.self)
                } ?? []
                budgets.sort { ($0.year, $0.month) > ($1.year, $1.month) }
                completion(.success(budgets))
            }
    }

    func fetchBudget(
        for userID: String,
        month: Int,
        year: Int,
        completion: @escaping (Result<Budget?, Error>) -> Void
    ) {
        db.collection("budgets")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let budget = snapshot?.documents.compactMap {
                    try? $0.data(as: Budget.self)
                }
                .first { $0.month == month && $0.year == year }
                completion(.success(budget))
            }
    }

    func deleteBudget(_ id: String, completion: @escaping (Error?) -> Void) {
        db.collection("budgets").document(id).delete(completion: completion)
    }
}
