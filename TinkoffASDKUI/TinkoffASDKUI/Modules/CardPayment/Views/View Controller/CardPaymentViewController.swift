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
    private lazy var cardFieldView = cardFieldFactory.assembleCardFieldView()
    private lazy var payButton = Button()
    private lazy var emailContainerView = UIView()
    private lazy var emailTextField = TextField()

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
        setupEmailContainerView()
        setupEmailTextField()

        presenter.viewDidLoad()
    }
}

// MARK: - ICardPaymentViewControllerInput

extension CardPaymentViewController {
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
}

// MARK: - Actions

extension CardPaymentViewController {
    @objc private func closeButtonAction(_ sender: UIBarButtonItem) {
        presenter.closeButtonPressed()
    }
}

// MARK: - UITableViewDataSource

extension CardPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        presenter.numberOfRows()
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self)
            cell.setContent(cardFieldView, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
            return cell
        case 1:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self)
            cell.setContent(emailContainerView, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
            return cell
        case 2:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self)
            cell.setContent(payButton, insets: UIEdgeInsets(vertical: 8, horizontal: 16))
            return cell
        default: return UITableViewCell()
        }
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

        let config = TextField.TextFieldConfiguration(
            delegate: nil,
            eventHandler: nil,
            content: .plain(text: "", style: .bodyL()),
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
}
