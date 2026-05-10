import Foundation

final class NewTransactionViewModel {

    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    var selectedCategory: TransactionCategory = .other
    var selectedType: TransactionType = .expense
    var selectedDate: Date = Date()

    func save(title: String, amount: String) {
        guard let uid = AuthService.shared.currentUserID else { return }

        let cleanAmount = amount
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)

        guard !title.isEmpty, let value = Double(cleanAmount), value > 0 else {
            onError?("Preencha todos os campos corretamente.")
            return
        }

        let transaction = Transaction(
            title: title,
            category: selectedCategory,
            amount: value,
            date: selectedDate,
            type: selectedType,
            userID: uid
        )

        FirestoreService.shared.addTransaction(transaction) { [weak self] error in
            if let error = error {
                self?.onError?(error.localizedDescription)
            } else {
                NotificationService.shared.scheduleNotification(for: transaction)
                self?.onSuccess?()
            }
        }
    }
}
