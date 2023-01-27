//
//  CardPaymentViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import UIKit

final class CardPaymentViewController: UIViewController, ICardPaymentViewControllerInput {

    // MARK: Dependencies

    private let presenter: ICardPaymentViewControllerOutput
    private let cardFieldFactory: ICardFieldFactory

    // MARK: Properties

    private lazy var tableView = UITableView()
    private lazy var savedCardView = SavedCardView()
    private lazy var cardFieldView = cardFieldFactory.assembleCardFieldView()
    private lazy var payButton = Button()
    private lazy var emailContainerView = UIView()
    private lazy var emailTextField = TextField()
    private lazy var switchView = SwitchView()

    // MARK: Initialization

    init(
        presenter: ICardPaymentViewControllerOutput,
        cardFieldFactory: ICardFieldFactory
    ) {
        self.presenter = presenter
        self.cardFieldFactory = cardFieldFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "init with coder is unavailable.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
        setupCardFieldView()
        setupPayButton()
        setupSwitchView()
        setupEmailContainerView()
        setupEmailTextField()

        presenter.viewDidLoad()
    }
}

// MARK: - ICardPaymentViewControllerInput

extension CardPaymentViewController {
    func forceValidateCardField() {
        cardFieldView.input.validateWholeForm()
    }

    func setPayButton(title: String) {
        let configuration = Button.Configuration(
            data: Button.Data(
                text: .basic(normal: title, highlighted: title, disabled: title),
                onTapAction: { [weak self] in self?.presenter.payButtonPressed() }
            ),
            style: .primary
        )
        payButton.configure(configuration)
    }

    func setPayButton(isEnabled: Bool) {
        payButton.isEnabled = isEnabled
    }

    func startLoadingPayButton() {
        payButton.startLoading()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }

    func stopLoadingPayButton() {
        payButton.stopLoading()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    func setEmailHeader(isError: Bool) {
        let color = isError ? ASDKColors.Foreground.negativeAccent : ASDKColors.Text.secondary.color
        let headerLabelStyle = UILabel.Style.bodyL().set(textColor: color)
        let content = UILabel.Content.plain(text: "Электронная почта", style: headerLabelStyle)
        let headerConfig = UILabel.Configuration(content: content)

        emailTextField.updateHeader(config: headerConfig)
    }

    func setEmailTextField(text: String) {
        let config = TextField.TextFieldConfiguration(
            delegate: self,
            eventHandler: { [weak self] event, textField in
                switch event {
                case .didBeginEditing:
                    self?.presenter.emailTextFieldDidBeginEditing()
                case .textDidChange:
                    self?.presenter.emailTextFieldDidChangeText(to: textField.text)
                case .didEndEditing:
                    self?.presenter.emailTextFieldDidEndEditing()
                }
            },
            content: .plain(text: text, style: .bodyL()),
            placeholder: .plain(text: "", style: .bodyL()),
            tintColor: nil,
            rightAccessoryView: TextField.AccessoryView(kind: .clearButton),
            isSecure: false,
            keyboardType: .default
        )
        let headerLabelStyle = UILabel.Style.bodyL().set(textColor: ASDKColors.Text.secondary.color)
        let content = UILabel.Content.plain(text: "Электронная почта", style: headerLabelStyle)
        let headerConfig = UILabel.Configuration(content: content)

        let emailConfig = TextField.Configuration(textField: config, headerLabel: headerConfig)
        emailTextField.configure(with: emailConfig)
    }

    func hideKeyboard() {
        view.endEditing(true)
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    func insert(row: Int) {
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        tableView.endUpdates()
    }

    func delete(row: Int) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - Actions

extension CardPaymentViewController {
    @objc private func closeButtonAction(_ sender: UIBarButtonItem) {
        presenter.closeButtonPressed()
    }
}

// MARK: - UITextFieldDelegate

extension CardPaymentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presenter.emailTextFieldDidPressReturn()
        return true
    }
}

// MARK: - UITableViewDataSource

extension CardPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(for: indexPath.row)
        let cell = tableView.dequeue(cellType: ContainerTableViewCell.self)

        switch cellType {
        case .savedCard:
            savedCardView.presenter = presenter.savedCardViewPresenter()
            cell.setContent(savedCardView, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
        case .cardField:
            cell.setContent(cardFieldView, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
        case .getReceipt:
            switchView.presenter = presenter.switchViewPresenter()
            cell.setContent(switchView, insets: UIEdgeInsets(vertical: 8, horizontal: 20))
        case .emailField:
            cell.setContent(emailContainerView, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
        case .payButton:
            cell.setContent(payButton, insets: UIEdgeInsets(vertical: 16, horizontal: 16))
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CardPaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        presenter.didSelectRow(at: indexPath.row)
    }
}

// MARK: - CardFieldDelegate

extension CardPaymentViewController: CardFieldDelegate {
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        presenter.cardFieldDidChangeState(isValid: result.isValid)
    }
}

// MARK: - Private

extension CardPaymentViewController {
    private func setupView() {
        view.backgroundColor = ASDKColors.Background.elevation1.color
    }

    private func setupNavigationBar() {
        navigationItem.title = "Оплата картой"

        let leftItem = UIBarButtonItem(
            title: "Закрыть",
            style: .plain,
            target: self,
            action: #selector(closeButtonAction(_:))
        )

        navigationItem.leftBarButtonItem = leftItem
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.register(ContainerTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
    }

    private func setupCardFieldView() {
        cardFieldView.delegate = self
    }

    private func setupPayButton() {
        payButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    private func setupSwitchView() {
        switchView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            switchView.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    private func setupEmailContainerView() {
        emailContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emailContainerView.heightAnchor.constraint(equalToConstant: 56),
        ])

        emailContainerView.backgroundColor = ASDKColors.Background.neutral1.color
        emailContainerView.layer.cornerRadius = 16

        emailContainerView.addSubview(emailTextField)
    }

    private func setupEmailTextField() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emailTextField.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor, constant: 12),
            emailTextField.rightAnchor.constraint(equalTo: emailContainerView.rightAnchor, constant: -12),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
        ])
    }
}
