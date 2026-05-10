import UserNotifications
import Foundation

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - Schedule daily notification for today's transactions
    /// Schedules a daily notification at 09:00 AM reminding the user of transactions for the day.
    func scheduleDailyTransactionReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_transaction_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "💰 Finanças do dia"
        content.body  = "Você tem transações programadas para hoje. Confira agora!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour   = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_transaction_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("NotificationService: erro ao agendar notificação - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule notification for a specific transaction
    func scheduleNotification(for transaction: Transaction) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = transaction.isIncome ? "💚 Entrada esperada" : "🔴 Saída esperada"
        content.body  = "\(transaction.title) — \(transaction.amount.brlFormatted)"
        content.sound = .default

        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: transaction.date)
        comps.hour   = 9
        comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id      = "transaction_\(transaction.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
