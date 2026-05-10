import UIKit

extension UIColor {

    // MARK: - Brand Colors
    static let appBackground   = UIColor(hex: "#F4F5F4")
    static let appCard         = UIColor.white
    static let appCardDark     = UIColor(hex: "#111113")
    static let appPrimary      = UIColor(hex: "#C840EB")   // magenta/pink
    static let appPrimaryLight = UIColor(hex: "#E8A0F5")
    static let appInput        = UIColor(hex: "#EFF0F0")
    static let appButton       = UIColor(hex: "#111113")

    // MARK: - Text
    static let textPrimary     = UIColor(hex: "#2C2C2E")
    static let textSecondary   = UIColor(hex: "#8E8E93")
    static let textMuted       = UIColor(hex: "#636366")

    // MARK: - Semantic
    static let incomeGreen     = UIColor(hex: "#30D158")
    static let expenseRed      = UIColor(hex: "#FF453A")
    static let separatorColor  = UIColor(hex: "#E5E5EA")

    // MARK: - Convenience init from hex
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
