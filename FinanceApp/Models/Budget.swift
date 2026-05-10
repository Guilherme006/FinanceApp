import Foundation
import FirebaseFirestoreSwift

struct Budget: Codable, Identifiable {
    @DocumentID var id: String?
    var month: Int        // 1-12
    var year: Int
    var limit: Double
    var userID: String

    var monthDate: Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        return Calendar.current.date(from: comps) ?? Date()
    }

    var displayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        let str = formatter.string(from: monthDate)
        return str.prefix(1).uppercased() + str.dropFirst()
    }
}
