//
//  CardPaymentViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import UIKit
import WebKit

final class CardPaymentViewController: UIViewController, ICardPaymentViewControllerInput {

    // MARK: Dependencies

    private let presenter: ICardPaymentViewControllerOutput

    // MARK: Properties

    private lazy var tableView = UITableView()

    private lazy var webView = WKWebView()

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
        setupWebView()
        setupTableView()

        presenter.viewDidLoad()
    }
}

// MARK: - ICardPaymentViewControllerInput

extension CardPaymentViewController {
    func startIgnoringInteractionEvents() {
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }

    func stopIgnoringInteractionEvents() {
        if #available(iOS 13.0, *) { isModalInPresentation = false }
        navigationController?.navigationBar.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
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

        switch cellType {
        case let .savedCard(cellPresenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = cellPresenter
            cell.insets = .cardCellsInsets
            return cell
        case let .cardField(cellPresenter):
            let cell = tableView.dequeue(cellType: CardFieldTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = cellPresenter
            cell.insets = .cardCellsInsets
            return cell
        case let .getReceipt(cellPresenter):
            let cell = tableView.dequeue(cellType: SwitchTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = cellPresenter
            cell.insets = .switchViewInsets
            return cell
        case let .emailField(cellPresenter):
            let cell = tableView.dequeue(cellType: EmailTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = cellPresenter
            cell.insets = .commonCellInsets
            return cell
        case let .payButton(cellPresenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = cellPresenter
            cell.insets = .payButtonInsets
            return cell
        }
    }
}

// MARK: - ThreeDSWebFlowDelegate

extension CardPaymentViewController: ThreeDSWebFlowDelegate {
    func hiddenWebViewToCollect3DSData() -> WKWebView { webView }
    func sourceViewControllerToPresent() -> UIViewController? { self }
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

    /// Не удалять, необходимо для корректной работы WebView
    private func setupWebView() {
        view.addSubview(webView)
        webView.pinEdgesToSuperview()
        webView.isHidden = true
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

        tableView.register(
            SavedCardTableCell.self,
            CardFieldTableCell.self,
            SwitchTableCell.self,
            EmailTableCell.self,
            PayButtonTableCell.self
        )

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
