import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Callbacks
    var onAddTransaction: ((Date) -> Void)?
    var onOpenBudgets: (() -> Void)?
    var onOpenProfile: (() -> Void)?
    var onLogout: (() -> Void)?

    // MARK: - ViewModel
    let viewModel = HomeViewModel()

    // MARK: - UI
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .appCard
        return v
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = .appBold(16)
        l.textColor = .textPrimary
        return l
    }()

    private let greetingSubLabel: UILabel = {
        let l = UILabel()
        l.text = "Vamos organizar suas finanças?"
        l.font = .appRegular(12)
        l.textColor = .textSecondary
        return l
    }()

    private let avatarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        btn.tintColor = .textSecondary
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50, weight: .regular), forImageIn: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 28
        btn.anchor(width: 56, height: 56)
        return btn
    }()

    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        btn.tintColor = .textSecondary
        return btn
    }()

    // Month Selector
    private lazy var prevMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .textSecondary
        btn.anchor(width: 28, height: 44)
        return btn
    }()

    private lazy var nextMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.tintColor = .textSecondary
        btn.anchor(width: 28, height: 44)
        return btn
    }()

    private let monthsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.delaysContentTouches = false
        sv.canCancelContentTouches = true
        return sv
    }()
    private let monthsStack = UIStackView()
    private var monthButtons: [UIButton] = []
    private var monthIndicators: [UIView] = []
    private let monthOffsets = Array(-12...12)

    private let budgetCard = BudgetCardView()

    // Transactions
    private let transactionsLabel: UILabel = {
        let l = UILabel()
        l.text = "LANÇAMENTOS"
        l.font = .appSemiBold(12)
        l.textColor = .textSecondary
        return l
    }()

    private let transactionCountBadge: UILabel = {
        let l = UILabel()
        l.font = .appBold(12)
        l.textColor = .textMuted
        l.textAlignment = .center
        l.backgroundColor = UIColor(hex: "#E9EAEA")
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.anchor(width: 34, height: 22)
        return l
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorColor = .separatorColor
        tv.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        tv.showsVerticalScrollIndicator = false
        tv.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        return tv
    }()

    private let emptyIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "doc.text"))
        iv.tintColor = .textSecondary
        iv.contentMode = .scaleAspectFit
        iv.anchor(width: 36, height: 36)
        return iv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Você ainda não registrou despesas ou receitas neste mês"
        l.font = .appRegular(14)
        l.textColor = .textSecondary
        l.textAlignment = .left
        l.numberOfLines = 0
        return l
    }()

    private lazy var emptyStateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyIconView, emptyLabel])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    private let transactionsHeaderSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .separatorColor
        return v
    }()

    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.backgroundColor = .appButton
        btn.tintColor = .white
        btn.layer.cornerRadius = 28
        btn.anchor(width: 56, height: 56)
        btn.addShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 4), radius: 10)
        return btn
    }()

    private let transactionsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .appCard
        v.roundCorners(8)
        return v
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        setupViewModel()
        setupMonthSelector()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        updateGreeting()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )

        // Pin contentView to contentLayoutGuide so the scroll view can grow with content
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .appBackground
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Header
        contentView.addSubview(headerView)
        headerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                          trailing: contentView.trailingAnchor)

        let greetingStack = UIStackView(arrangedSubviews: [greetingLabel, greetingSubLabel])
        greetingStack.axis = .vertical
        greetingStack.spacing = 2

        headerView.addSubview(avatarButton)
        headerView.addSubview(greetingStack)
        headerView.addSubview(logoutButton)

        avatarButton.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor,
                            paddingTop: 20, paddingLeading: 16)
        greetingStack.anchor(top: headerView.topAnchor, leading: avatarButton.trailingAnchor,
                             paddingTop: 22, paddingLeading: 12)
        logoutButton.anchor(top: headerView.topAnchor, trailing: headerView.trailingAnchor,
                            paddingTop: 28, paddingTrailing: 16, width: 32, height: 32)
        headerView.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 22).isActive = true

        // Month selector
        let monthSelectorStack = buildMonthSelectorStack()
        monthSelectorStack.backgroundColor = .appCard
        contentView.addSubview(monthSelectorStack)
        monthSelectorStack.anchor(
            top: headerView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 0, paddingLeading: 8, paddingTrailing: 8
        )

        // Budget card
        contentView.addSubview(budgetCard)
        budgetCard.anchor(top: monthSelectorStack.bottomAnchor, leading: contentView.leadingAnchor,
                          trailing: contentView.trailingAnchor,
                          paddingTop: 12, paddingLeading: 16, paddingTrailing: 16)

        contentView.addSubview(transactionsCard)
        transactionsCard.anchor(
            top: budgetCard.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        transactionsCard.addSubview(transactionsLabel)
        transactionsCard.addSubview(transactionCountBadge)
        transactionsCard.addSubview(transactionsHeaderSeparator)
        transactionsLabel.anchor(top: transactionsCard.topAnchor, leading: transactionsCard.leadingAnchor,
                                 paddingTop: 18, paddingLeading: 16)
        transactionCountBadge.anchor(top: transactionsCard.topAnchor, trailing: transactionsCard.trailingAnchor,
                                     paddingTop: 13, paddingTrailing: 20)
        transactionsHeaderSeparator.anchor(top: transactionsLabel.bottomAnchor,
                                           leading: transactionsCard.leadingAnchor,
                                           trailing: transactionsCard.trailingAnchor,
                                           paddingTop: 18,
                                           height: 1)

        transactionsCard.addSubview(emptyStateStack)
        emptyStateStack.anchor(top: transactionsHeaderSeparator.bottomAnchor,
                               leading: transactionsCard.leadingAnchor,
                               trailing: transactionsCard.trailingAnchor,
                               paddingTop: 22,
                               paddingLeading: 28,
                               paddingTrailing: 28)

        // TableView with an explicit height constraint updated when data loads
        transactionsCard.addSubview(tableView)
        tableView.anchor(top: transactionsHeaderSeparator.bottomAnchor,
                         leading: transactionsCard.leadingAnchor,
                         trailing: transactionsCard.trailingAnchor)
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        tableView.isScrollEnabled = false
        tableView.rowHeight = 72
        tableView.estimatedRowHeight = 72
        tableView.delegate   = self
        tableView.dataSource = self

        // contentView height driven by tableView so the scroll view resizes correctly
        transactionsCard.bottomAnchor.constraint(greaterThanOrEqualTo: emptyStateStack.bottomAnchor, constant: 22).isActive = true
        transactionsCard.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8).isActive = true
        contentView.bottomAnchor.constraint(equalTo: transactionsCard.bottomAnchor, constant: 96).isActive = true

        // FAB add button
        view.addSubview(addButton)
        addButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
                         paddingBottom: 24, paddingTrailing: 24)

        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)

        budgetCard.onSettingsTapped = { [weak self] in self?.onOpenBudgets?() }
    }

    private func buildMonthSelectorStack() -> UIStackView {
        monthButtons.removeAll()
        monthIndicators.removeAll()

        monthsStack.axis = .horizontal
        monthsStack.alignment = .fill
        monthsStack.spacing = 12
        monthsStack.translatesAutoresizingMaskIntoConstraints = false

        monthOffsets.forEach { offset in
            let container = UIView()
            container.isUserInteractionEnabled = true
            container.tag = offset
            container.translatesAutoresizingMaskIntoConstraints = false

            let button = UIButton(type: .system)
            button.titleLabel?.font = .appMedium(12)
            button.setTitleColor(.textSecondary, for: .normal)
            button.tag = offset
            button.isUserInteractionEnabled = false
            button.translatesAutoresizingMaskIntoConstraints = false

            let indicator = UIView()
            indicator.backgroundColor = .appPrimary
            indicator.layer.cornerRadius = 1.5
            indicator.isHidden = true
            indicator.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(button)
            container.addSubview(indicator)

            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: 52),
                button.topAnchor.constraint(equalTo: container.topAnchor),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                button.heightAnchor.constraint(equalToConstant: 32),
                indicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.widthAnchor.constraint(equalToConstant: 20),
                indicator.heightAnchor.constraint(equalToConstant: 3)
            ])

            let tap = UITapGestureRecognizer(target: self, action: #selector(monthSlotTapped(_:)))
            container.addGestureRecognizer(tap)

            monthButtons.append(button)
            monthIndicators.append(indicator)
            monthsStack.addArrangedSubview(container)
        }

        monthsScrollView.addSubview(monthsStack)
        NSLayoutConstraint.activate([
            monthsStack.topAnchor.constraint(equalTo: monthsScrollView.contentLayoutGuide.topAnchor),
            monthsStack.leadingAnchor.constraint(equalTo: monthsScrollView.contentLayoutGuide.leadingAnchor),
            monthsStack.bottomAnchor.constraint(equalTo: monthsScrollView.contentLayoutGuide.bottomAnchor),
            monthsStack.trailingAnchor.constraint(equalTo: monthsScrollView.contentLayoutGuide.trailingAnchor),
            monthsStack.heightAnchor.constraint(equalTo: monthsScrollView.frameLayoutGuide.heightAnchor)
        ])

        let mainStack = UIStackView(arrangedSubviews: [prevMonthButton, monthsScrollView, nextMonthButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .fill
        mainStack.spacing = 4
        mainStack.anchor(height: 44)

        prevMonthButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)

        return mainStack
    }

    private func setupViewModel() {
        viewModel.onTransactionsUpdated = { [weak self] in
            DispatchQueue.main.async { self?.updateTransactionUI() }
        }
        viewModel.onBudgetUpdated = { [weak self] in
            DispatchQueue.main.async { self?.updateBudgetCard() }
        }
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    private func setupMonthSelector() {
        updateMonthSelector()
    }

    private func updateMonthSelector() {
        let cal = Calendar.current
        for (index, offset) in monthOffsets.enumerated() {
            guard let date = cal.date(byAdding: .month, value: offset, to: viewModel.selectedDate.startOfMonth) else { continue }
            let isSelected = (offset == 0)
            monthButtons[index].setTitle(date.monthAbbrev, for: .normal)
            monthButtons[index].setTitleColor(isSelected ? .textPrimary : .textSecondary, for: .normal)
            monthButtons[index].titleLabel?.font = isSelected ? .appBold(12) : .appMedium(12)
            monthIndicators[index].isHidden = !isSelected
        }

        view.layoutIfNeeded()
        if let selectedIndex = monthOffsets.firstIndex(of: 0), selectedIndex < monthsStack.arrangedSubviews.count {
            let selectedView = monthsStack.arrangedSubviews[selectedIndex]
            let targetX = selectedView.frame.midX - monthsScrollView.bounds.width / 2
            let maxX = max(0, monthsScrollView.contentSize.width - monthsScrollView.bounds.width)
            monthsScrollView.setContentOffset(CGPoint(x: min(max(0, targetX), maxX), y: 0), animated: false)
        }
    }

    private func updateGreeting() {
        let user = AppUser.loadLocally()
        let name = user?.name.components(separatedBy: " ").first?.uppercased() ?? "USUÁRIO"
        greetingLabel.text = "OLÁ, \(name)!"
    }

    private func updateBudgetCard() {
        budgetCard.configure(
            month: viewModel.monthTitle,
            availableBalance: viewModel.availableBalance,
            used: viewModel.totalExpense,
            limit: viewModel.budgetLimit
        )
    }

    private func updateTransactionUI() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = viewModel.transactions.isEmpty ? 92 : CGFloat(viewModel.transactions.count) * 72
        transactionCountBadge.text = "\(viewModel.transactions.count)"
        emptyStateStack.isHidden = !viewModel.transactions.isEmpty
        tableView.isHidden  = viewModel.transactions.isEmpty
    }

    // MARK: - Public
    func reloadData() { viewModel.loadData() }

    // MARK: - Actions
    @objc private func addTapped() {
        onAddTransaction?(viewModel.selectedDate)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Sair", message: "Deseja fazer logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive) { [weak self] _ in
            self?.onLogout?()
        })
        present(alert, animated: true)
    }

    @objc private func avatarTapped() { onOpenProfile?() }

    @objc private func prevMonthTapped() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.selectedDate) else { return }
        viewModel.selectMonth(newDate.startOfMonth)
        updateMonthSelector()
    }

    @objc private func nextMonthTapped() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.selectedDate) else { return }
        viewModel.selectMonth(newDate.startOfMonth)
        updateMonthSelector()
    }

    @objc private func monthSlotTapped(_ gesture: UITapGestureRecognizer) {
        guard let slot = gesture.view else { return }
        let offset = slot.tag
        guard offset != 0,
              let newDate = Calendar.current.date(byAdding: .month, value: offset, to: viewModel.selectedDate) else { return }
        viewModel.selectMonth(newDate.startOfMonth)
        updateMonthSelector()
    }

    @objc private func monthButtonTapped(_ sender: UIButton) {
        let offset = sender.tag
        guard offset != 0,
              let newDate = Calendar.current.date(byAdding: .month, value: offset, to: viewModel.selectedDate) else { return }
        viewModel.selectMonth(newDate.startOfMonth)
        updateMonthSelector()
    }
}

// MARK: - UITableViewDataSource / Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as! TransactionCell
        cell.configure(with: viewModel.transactions[indexPath.row])
        cell.onDeleteTapped = { [weak self] in
            self?.viewModel.deleteTransaction(at: indexPath.row) { error in
                if let error = error {
                    let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
}
