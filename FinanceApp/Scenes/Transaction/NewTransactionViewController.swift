import UIKit

final class NewTransactionViewController: UIViewController {

    var initialDate: Date?
    var onDismiss: (() -> Void)?

    private let viewModel = NewTransactionViewModel()

    // MARK: - UI
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .appCard
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.text = "NOVO LANÇAMENTO"
        l.font = .appBold(16)
        l.textColor = .textPrimary
        return l
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .textSecondary
        return btn
    }()

    private let titleField      = CustomTextField(placeholder: "Título da transação")
    private let amountField     = CustomTextField(placeholder: "R$ 0,00", keyboardType: .decimalPad)
    private let categoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Categoria", for: .normal)
        btn.setTitleColor(.textMuted, for: .normal)
        btn.setImage(UIImage(systemName: "tag"), for: .normal)
        btn.tintColor = .textMuted
        btn.backgroundColor = .appInput
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.imageEdgeInsets   = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        btn.anchor(height: 54)
        return btn
    }()

    private let dateField = CustomTextField(placeholder: "00/00/0000", keyboardType: .numbersAndPunctuation)

    private let incomeButton  = PrimaryButton(title: "Entrada ↑", style: .outlined(color: .incomeGreen))
    private let expenseButton = PrimaryButton(title: "Saída ↓",   style: .outlined(color: .expenseRed))

    private let saveButton = PrimaryButton(title: "Salvar")

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .white
        a.hidesWhenStopped = true
        return a
    }()

    private var datePicker: UIDatePicker!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()
        setupViewModel()
        setupDatePicker()
        if let date = initialDate { viewModel.selectedDate = date }
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(containerView)
        containerView.anchor(leading: view.leadingAnchor, bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor)

        // Header
        containerView.addSubview(headerLabel)
        containerView.addSubview(closeButton)
        headerLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor,
                           paddingTop: 24, paddingLeading: 24)
        closeButton.anchor(top: containerView.topAnchor, trailing: containerView.trailingAnchor,
                           paddingTop: 20, paddingTrailing: 20, width: 32, height: 32)

        // Category + Date row
        let catDateStack = UIStackView(arrangedSubviews: [categoryButton, dateField])
        catDateStack.axis = .horizontal
        catDateStack.spacing = 12
        catDateStack.distribution = .fillEqually

        // Type buttons row
        let typeStack = UIStackView(arrangedSubviews: [incomeButton, expenseButton])
        typeStack.axis = .horizontal
        typeStack.spacing = 12
        typeStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [
            titleField, catDateStack, amountField, typeStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16

        containerView.addSubview(mainStack)
        mainStack.anchor(top: headerLabel.bottomAnchor, leading: containerView.leadingAnchor,
                         trailing: containerView.trailingAnchor,
                         paddingTop: 20, paddingLeading: 24, paddingTrailing: 24)

        containerView.addSubview(saveButton)
        saveButton.anchor(top: mainStack.bottomAnchor, leading: containerView.leadingAnchor,
                          bottom: containerView.safeAreaLayoutGuide.bottomAnchor, trailing: containerView.trailingAnchor,
                          paddingTop: 24, paddingLeading: 24, paddingBottom: 16, paddingTrailing: 24)

        saveButton.addSubview(activityIndicator)
        activityIndicator.centerIn(saveButton)

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        incomeButton.addTarget(self, action: #selector(incomeSelected), for: .touchUpInside)
        expenseButton.addTarget(self, action: #selector(expenseSelected), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)

        // Default selection
        expenseSelected()

        let tap = UITapGestureRecognizer(target: self, action: #selector(bgTapped))
        view.addGestureRecognizer(tap)
    }

    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "pt_BR")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateField.textField.inputView = datePicker
        updateDateField()
    }

    private func setupViewModel() {
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.setLoading(false)
                self?.dismiss(animated: true) { self?.onDismiss?() }
            }
        }
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async {
                self?.setLoading(false)
                let alert = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    private func updateDateField() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateField.textField.text = formatter.string(from: viewModel.selectedDate)
    }

    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func bgTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) { dismiss(animated: true) }
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        setLoading(true)
        viewModel.save(title: titleField.text, amount: amountField.text)
    }

    @objc private func incomeSelected() {
        viewModel.selectedType = .income
        incomeButton.backgroundColor = UIColor.incomeGreen.withAlphaComponent(0.15)
        expenseButton.backgroundColor = .clear
    }

    @objc private func expenseSelected() {
        viewModel.selectedType = .expense
        expenseButton.backgroundColor = UIColor.expenseRed.withAlphaComponent(0.15)
        incomeButton.backgroundColor = .clear
    }

    @objc private func dateChanged() {
        viewModel.selectedDate = datePicker.date
        updateDateField()
    }

    @objc private func categoryTapped() {
        let alert = UIAlertController(title: "Categoria", message: nil, preferredStyle: .actionSheet)
        for cat in TransactionCategory.allCases {
            alert.addAction(UIAlertAction(title: cat.displayName, style: .default) { [weak self] _ in
                self?.viewModel.selectedCategory = cat
                self?.categoryButton.setTitle(cat.displayName, for: .normal)
                self?.categoryButton.setTitleColor(.textPrimary, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func setLoading(_ loading: Bool) {
        saveButton.setTitle(loading ? "" : "Salvar", for: .normal)
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        saveButton.isEnabled = !loading
    }
}
