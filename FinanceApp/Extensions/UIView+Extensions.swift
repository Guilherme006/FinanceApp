import UIKit

extension UIView {

    // MARK: - Auto Layout helpers
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        paddingLeading: CGFloat = 0,
        paddingBottom: CGFloat = 0,
        paddingTrailing: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top { topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true }
        if let leading = leading { leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true }
        if let bottom = bottom { bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true }
        if let trailing = trailing { trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true }
        if let width = width { widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let height = height { heightAnchor.constraint(equalToConstant: height).isActive = true }
    }

    func centerIn(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = superview else { return }
        anchor(
            top: superview.topAnchor,
            leading: superview.leadingAnchor,
            bottom: superview.bottomAnchor,
            trailing: superview.trailingAnchor,
            paddingTop: padding.top,
            paddingLeading: padding.left,
            paddingBottom: padding.bottom,
            paddingTrailing: padding.right
        )
    }

    func roundCorners(_ radius: CGFloat = 12) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }

    func addShadow(color: UIColor = .black, opacity: Float = 0.2, offset: CGSize = .zero, radius: CGFloat = 8) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}

// MARK: - Number Formatter
extension Double {
    var brlFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
}

// MARK: - Date Formatter
extension Date {
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }

    var monthYearFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM / yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self).uppercased()
    }

    var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self).uppercased()
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }
}
