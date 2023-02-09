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

    // MARK: Properties

    private lazy var tableView = UITableView()
    private lazy var savedCardView = SavedCardView()
    private lazy var cardFieldView = CardFieldView()
    private lazy var switchView = SwitchView()
    private lazy var emailView = EmailView()
    private lazy var payButton = Button(
        configuration: Button.Configuration(style: .primaryTinkoff, contentSize: .basicLarge),
        action: { [presenter] in presenter.payButtonPressed() }
    )

    // MARK: Initialization

    init(presenter: ICardPaymentViewControllerOutput) {
        self.presenter = presenter
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

        presenter.viewDidLoad()
    }
}

// MARK: - ICardPaymentViewControllerInput

extension CardPaymentViewController {
    func setPayButton(title: String) {
        payButton.setTitle(title)
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

    func hideKeyboard() {
        view.endEditing(true)
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    func insert(row: Int) {
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        tableView.endUpdates()
    }

    func delete(row: Int) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        tableView.endUpdates()
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
        return presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(for: indexPath.row)
        let cell = tableView.dequeue(cellType: ContainerTableViewCell.self)

        switch cellType {
        case let .savedCard(cellPresenter):
            savedCardView.presenter = cellPresenter
            cell.setContent(savedCardView, insets: .cardCellsInsets)
        case let .cardField(cellPresenter):
            cardFieldView.presenter = cellPresenter
            cell.setContent(cardFieldView, insets: .cardCellsInsets)
        case let .getReceipt(cellPresenter):
            switchView.presenter = cellPresenter
            cell.setContent(switchView, insets: .switchViewInsets)
        case let .emailField(cellPresenter):
            emailView.presenter = cellPresenter
            cell.setContent(emailView, insets: .commonCellInsets)
        case .payButton:
            cell.setContent(payButton, insets: .payButtonInsets)
        }

        return cell
    }
}

// MARK: - Private

extension CardPaymentViewController {
    private func setupView() {
        view.backgroundColor = ASDKColors.Background.elevation1.color
    }

    private func setupNavigationBar() {
        navigationItem.title = Loc.Acquiring.PaymentNewCard.screenTitle

        let leftItem = UIBarButtonItem(
            title: Loc.Acquiring.PaymentNewCard.buttonClose,
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
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = .commonCellHeight
    }
}

// MARK: - Constants

private extension CGFloat {
    static let commonCellHeight: CGFloat = 56
}

private extension UIEdgeInsets {
    static let cardCellsInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    static let commonCellInsets = UIEdgeInsets(vertical: 8, horizontal: 16)
    static let switchViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 16, right: 20)
    static let payButtonInsets = UIEdgeInsets(vertical: 16, horizontal: 16)
}
