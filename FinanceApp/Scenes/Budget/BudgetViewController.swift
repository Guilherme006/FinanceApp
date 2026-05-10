import UIKit

final class BudgetViewController: UIViewController {

    var onDismiss: (() -> Void)?
    private let viewModel = BudgetViewModel()

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "ORÇAMENTOS MENSAIS"
        l.font = .appBold(16)
        l.textColor = .textPrimary
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Organize seus limites de gastos por mês"
        l.font = .appRegular(13)
        l.textColor = .textSecondary
        return l
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .textPrimary
        return btn
    }()

    // New budget form
    private let formCard: UIView = {
        let v = UIView()
        v.backgroundColor = .appCard
        v.roundCorners(16)
        return v
    }()

    private let newBudgetLabel: UILabel = {
        let l = UILabel()
        l.text = "NOVO ORÇAMENTO"
        l.font = .appSemiBold(12)
        l.textColor = .textSecondary
        return l
    }()

    private lazy var monthPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "pt_BR")
        dp.tintColor = .appPrimary
        return dp
    }()

    private let amountField = CustomTextField(placeholder: "R$ 0,00", keyboardType: .decimalPad)
    private let addButton   = PrimaryButton(title: "Adicionar")

    // List
    private let listLabel: UILabel = {
        let l = UILabel()
        l.text = "ORÇAMENTOS CADASTRADOS"
        l.font = .appSemiBold(12)
        l.textColor = .textSecondary
        return l
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorColor = .separatorColor
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.register(BudgetCell.self, forCellReuseIdentifier: BudgetCell.identifier)
        return tv
    }()

    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        setupViewModel()
        viewModel.loadBudgets()
    }

    // MARK: - Setup
    private func setupUI() {
        let scrollView = UIScrollView()
        let contentView = UIView()

        view.addSubview(scrollView)
        scrollView.fillSuperview()
        scrollView.addSubview(contentView)
        contentView.fillSuperview()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Back + Title
        contentView.addSubview(backButton)
        backButton.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                          paddingTop: 16, paddingLeading: 8, width: 40, height: 40)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        titleLabel.anchor(top: backButton.bottomAnchor, leading: contentView.leadingAnchor,
                          paddingTop: 8, paddingLeading: 20)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, leading: contentView.leadingAnchor,
                             paddingTop: 4, paddingLeading: 20)

        // Form card
        contentView.addSubview(formCard)
        formCard.anchor(top: subtitleLabel.bottomAnchor, leading: contentView.leadingAnchor,
                        trailing: contentView.trailingAnchor,
                        paddingTop: 24, paddingLeading: 16, paddingTrailing: 16)

        formCard.addSubview(newBudgetLabel)
        newBudgetLabel.anchor(top: formCard.topAnchor, leading: formCard.leadingAnchor,
                              paddingTop: 16, paddingLeading: 16)

        // Picker + amount row
        let pickerAmountStack = UIStackView(arrangedSubviews: [monthPicker, amountField])
        pickerAmountStack.axis = .horizontal
        pickerAmountStack.spacing = 12
        pickerAmountStack.distribution = .fillEqually
        formCard.addSubview(pickerAmountStack)
        pickerAmountStack.anchor(top: newBudgetLabel.bottomAnchor, leading: formCard.leadingAnchor,
                                 trailing: formCard.trailingAnchor,
                                 paddingTop: 12, paddingLeading: 16, paddingTrailing: 16)

        formCard.addSubview(addButton)
        addButton.anchor(top: pickerAmountStack.bottomAnchor, leading: formCard.leadingAnchor,
                         bottom: formCard.bottomAnchor, trailing: formCard.trailingAnchor,
                         paddingTop: 12, paddingLeading: 16, paddingBottom: 16, paddingTrailing: 16)

        // List
        contentView.addSubview(listLabel)
        listLabel.anchor(top: formCard.bottomAnchor, leading: contentView.leadingAnchor,
                         paddingTop: 24, paddingLeading: 20)

        let listCard = UIView()
        listCard.backgroundColor = .appCard
        listCard.roundCorners(8)
        contentView.addSubview(listCard)
        listCard.anchor(top: listLabel.bottomAnchor, leading: contentView.leadingAnchor,
                        bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                        paddingTop: 12, paddingLeading: 16, paddingBottom: 24, paddingTrailing: 16)

        listCard.addSubview(tableView)
        tableView.anchor(top: listCard.topAnchor, leading: listCard.leadingAnchor,
                         bottom: listCard.bottomAnchor, trailing: listCard.trailingAnchor)
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 1)
        tableViewHeightConstraint?.isActive = true
        tableView.isScrollEnabled = false
        tableView.delegate   = self
        tableView.dataSource = self

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addBudget), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func setupViewModel() {
        viewModel.onBudgetsUpdated = { [weak self] in
            DispatchQueue.main.async { self?.updateBudgetList() }
        }
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    // MARK: - Actions
    @objc private func addBudget() {
        view.endEditing(true)
        let cleanAmount = amountField.text
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)

        guard let value = Double(cleanAmount), value > 0 else {
            let alert = UIAlertController(title: "Atenção", message: "Informe um valor válido.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let cal   = Calendar.current
        let month = cal.component(.month, from: monthPicker.date)
        let year  = cal.component(.year,  from: monthPicker.date)

        viewModel.addBudget(month: month, year: year, limit: value) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    self?.amountField.textField.text = ""
                }
            }
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        onDismiss?()
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func updateBudgetList() {
        tableView.reloadData()
        tableView.layoutIfNeeded()

        let rowsHeight = max(CGFloat(viewModel.budgets.count) * 56, viewModel.budgets.isEmpty ? 1 : 56)
        tableViewHeightConstraint?.constant = rowsHeight
        view.layoutIfNeeded()
    }
}

// MARK: - TableView
extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.budgets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BudgetCell.identifier, for: indexPath) as! BudgetCell
        cell.configure(with: viewModel.budgets[indexPath.row])
        cell.onDeleteTapped = { [weak self] in
            self?.viewModel.deleteBudget(at: indexPath.row) { error in
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
        UITableView.automaticDimension
    }
}
