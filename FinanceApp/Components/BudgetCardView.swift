import UIKit

final class BudgetCardView: UIView {

    // MARK: - UI
    private let monthLabel: UILabel = {
        let l = UILabel()
        l.font = .appMedium(14)
        l.textColor = UIColor.white.withAlphaComponent(0.72)
        return l
    }()

    private let settingsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.82)
        return btn
    }()

    private let budgetTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Orçamento disponível"
        l.font = .appRegular(13)
        l.textColor = UIColor.white.withAlphaComponent(0.62)
        return l
    }()

    private let budgetAmountLabel: UILabel = {
        let l = UILabel()
        l.font = .appBold(28)
        l.textColor = .white
        l.text = "R$ 0,00"
        return l
    }()

    private let setLimitButton: PrimaryButton = {
        let btn = PrimaryButton(title: "Definir orçamento", style: .outlined(color: .appPrimary))
        return btn
    }()

    private let progressBar: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.progressTintColor = .appPrimary
        p.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        p.layer.cornerRadius = 4
        p.clipsToBounds = true
        p.anchor(height: 6)
        return p
    }()

    private let usedLabel: UILabel = {
        let l = UILabel()
        l.font = .appRegular(12)
        l.textColor = UIColor.white.withAlphaComponent(0.58)
        l.text = "Usado"
        return l
    }()

    private let limitLabel: UILabel = {
        let l = UILabel()
        l.font = .appRegular(12)
        l.textColor = UIColor.white.withAlphaComponent(0.58)
        l.text = "Limite"
        return l
    }()

    private let usedValueLabel: UILabel = {
        let l = UILabel()
        l.font = .appMedium(14)
        l.textColor = .white
        return l
    }()

    private let limitValueLabel: UILabel = {
        let l = UILabel()
        l.font = .appMedium(14)
        l.textColor = .white
        l.textAlignment = .right
        return l
    }()

    var onSettingsTapped: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .appCardDark
        roundCorners(20)

        // Month header row
        addSubview(monthLabel)
        addSubview(settingsButton)
        monthLabel.anchor(top: topAnchor, leading: leadingAnchor, paddingTop: 20, paddingLeading: 20)
        settingsButton.anchor(top: topAnchor, trailing: trailingAnchor, paddingTop: 16, paddingTrailing: 16, width: 28, height: 28)

        // Budget title
        addSubview(budgetTitleLabel)
        budgetTitleLabel.anchor(top: monthLabel.bottomAnchor, leading: leadingAnchor, paddingTop: 16, paddingLeading: 20)

        // Amount or set limit button
        addSubview(budgetAmountLabel)
        budgetAmountLabel.anchor(top: budgetTitleLabel.bottomAnchor, leading: leadingAnchor, paddingTop: 4, paddingLeading: 20)

        addSubview(setLimitButton)
        setLimitButton.anchor(top: budgetTitleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor,
                              paddingTop: 8, paddingLeading: 20, paddingTrailing: 20)

        // Progress bar
        addSubview(progressBar)
        progressBar.anchor(top: budgetAmountLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor,
                           paddingTop: 16, paddingLeading: 20, paddingTrailing: 20)

        // Used / Limit row
        let usedStack = makeVStack(top: usedLabel, bottom: usedValueLabel)
        let limitStack = makeVStack(top: limitLabel, bottom: limitValueLabel, alignment: .trailing)

        addSubview(usedStack)
        addSubview(limitStack)
        usedStack.anchor(top: progressBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor,
                         paddingTop: 10, paddingLeading: 20, paddingBottom: 20)
        limitStack.anchor(top: progressBar.bottomAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                          paddingTop: 10, paddingBottom: 20, paddingTrailing: 20)

        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        setLimitButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    private func makeVStack(top: UILabel, bottom: UILabel, alignment: UIStackView.Alignment = .leading) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [top, bottom])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = alignment
        return stack
    }

    @objc private func settingsTapped() { onSettingsTapped?() }

    // MARK: - Configure
    func configure(month: String, availableBalance: Double, used: Double, limit: Double?) {
        monthLabel.text = month

        if let limit = limit, limit > 0 {
            setLimitButton.isHidden = true
            budgetAmountLabel.isHidden = false
            progressBar.isHidden = false

            budgetAmountLabel.text = availableBalance.brlFormatted
            let progress = min(Float(used / limit), 1.0)
            progressBar.setProgress(progress, animated: true)
            progressBar.progressTintColor = progress >= 1.0 ? .expenseRed : .appPrimary

            usedValueLabel.text = used.brlFormatted
            limitValueLabel.text = limit.brlFormatted
        } else {
            setLimitButton.isHidden = false
            budgetAmountLabel.isHidden = true
            progressBar.isHidden = true
            usedValueLabel.text = "R$ 0,00"
            limitValueLabel.text = "∞"
        }
    }
}
