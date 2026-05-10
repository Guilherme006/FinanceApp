import Foundation

final class BudgetViewModel {

    var onBudgetsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var budgets: [Budget] = []

    func loadBudgets() {
        guard let uid = AuthService.shared.currentUserID else { return }
        FirestoreService.shared.fetchBudgets(for: uid) { [weak self] result in
            switch result {
            case .success(let items):
                self?.budgets = items
                self?.onBudgetsUpdated?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func addBudget(month: Int, year: Int, limit: Double, completion: @escaping (Error?) -> Void) {
        guard let uid = AuthService.shared.currentUserID else { return }
        let budget = Budget(month: month, year: year, limit: limit, userID: uid)
        FirestoreService.shared.addBudget(budget) { [weak self] error in
            if error == nil { self?.loadBudgets() }
            completion(error)
        }
    }

    func deleteBudget(at index: Int, completion: @escaping (Error?) -> Void) {
        guard index < budgets.count, let id = budgets[index].id else { return }
        FirestoreService.shared.deleteBudget(id) { [weak self] error in
            if error == nil {
                self?.budgets.remove(at: index)
                self?.onBudgetsUpdated?()
            }
            completion(error)
        }
    }
}
