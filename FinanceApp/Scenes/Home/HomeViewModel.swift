import Foundation

final class HomeViewModel {

    // MARK: - Published state
    var onTransactionsUpdated: (() -> Void)?
    var onBudgetUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var transactions: [Transaction] = []
    private(set) var budget: Budget?
    private(set) var selectedDate: Date = Date()

    // Derived values
    var totalIncome:  Double { transactions.filter { $0.isIncome  }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount } }
    var availableBalance: Double { totalIncome - totalExpense }
    var budgetLimit: Double? { budget?.limit }

    var monthTitle: String { selectedDate.monthYearFormatted }

    // MARK: - Month navigation
    func months(around count: Int = 12) -> [Date] {
        var result: [Date] = []
        let cal = Calendar.current
        for i in stride(from: -(count/2), through: count/2, by: 1) {
            if let d = cal.date(byAdding: .month, value: i, to: Date().startOfMonth) {
                result.append(d)
            }
        }
        return result
    }

    func selectMonth(_ date: Date) {
        selectedDate = date
        loadData()
    }

    // MARK: - Load
    func loadData() {
        guard let uid = AuthService.shared.currentUserID else { return }
        let cal = Calendar.current
        let month = cal.component(.month, from: selectedDate)
        let year  = cal.component(.year,  from: selectedDate)

        FirestoreService.shared.fetchTransactions(for: uid, month: month, year: year) { [weak self] result in
            switch result {
            case .success(let items):
                self?.transactions = items
                self?.onTransactionsUpdated?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }

        FirestoreService.shared.fetchBudget(for: uid, month: month, year: year) { [weak self] result in
            switch result {
            case .success(let b):
                self?.budget = b
                self?.onBudgetUpdated?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    // MARK: - Delete transaction
    func deleteTransaction(at index: Int, completion: @escaping (Error?) -> Void) {
        guard index < transactions.count,
              let id = transactions[index].id else { return }
        FirestoreService.shared.deleteTransaction(id) { [weak self] error in
            if error == nil {
                self?.transactions.remove(at: index)
                self?.onTransactionsUpdated?()
            }
            completion(error)
        }
    }
}
