import Foundation
import FirebaseFirestoreSwift

enum TransactionType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
}

enum TransactionCategory: String, Codable, CaseIterable {
    case market      = "market"
    case gift        = "gift"
    case utilities   = "utilities"
    case rent        = "rent"
    case salary      = "salary"
    case transport   = "transport"
    case health      = "health"
    case education   = "education"
    case leisure     = "leisure"
    case other       = "other"

    var displayName: String {
        switch self {
        case .market:    return "Mercado"
        case .gift:      return "Presente"
        case .utilities: return "Utilidades"
        case .rent:      return "Aluguel"
        case .salary:    return "Salário"
        case .transport: return "Transporte"
        case .health:    return "Saúde"
        case .education: return "Educação"
        case .leisure:   return "Lazer"
        case .other:     return "Outros"
        }
    }

    var iconName: String {
        switch self {
        case .market:    return "basket"
        case .gift:      return "gift"
        case .utilities: return "bolt"
        case .rent:      return "house"
        case .salary:    return "briefcase"
        case .transport: return "car"
        case .health:    return "heart"
        case .education: return "book"
        case .leisure:   return "gamecontroller"
        case .other:     return "tag"
        }
    }
}

struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var category: TransactionCategory
    var amount: Double
    var date: Date
    var type: TransactionType
    var userID: String

    var isIncome: Bool { type == .income }
}
