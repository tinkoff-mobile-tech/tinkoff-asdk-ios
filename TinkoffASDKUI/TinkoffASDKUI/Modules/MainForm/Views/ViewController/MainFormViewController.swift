//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormViewController: UIViewController, PullableContainerContent {
    // MARK: PullableContainer Properties

    var scrollView: UIScrollView { tableView }
    var pullableContainerContentHeight: CGFloat { 900 }
    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    // MARK: Dependencies

    private let presenter: IMainFormPresenter

    // MARK: Subviews

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var tableHeaderView = MainFormTableHeaderView(frame: .tableHeaderInitialFrame)

    // MARK: Init

    init(presenter: IMainFormPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.viewDidLoad()
    }

    // MARK: Initial Configuration

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()
        tableView.tableHeaderView = tableHeaderView
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            MainFormOrderDetailsTableCell.self,
            SavedCardTableCell.self,
            SwitchTableCell.self,
            EmailTableCell.self,
            PayButtonTableCell.self,
            TextHeaderCell.self,
            AvatarTableViewCell.self
        )
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func reloadData() {
        tableView.reloadData()
    }

    func insertRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }

    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }
}

// MARK: - PullableContainerContent Methods

extension MainFormViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }
}

// MARK: - UITableViewDataSource

extension MainFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(at: indexPath)

        switch cellType {
        case let .orderDetails(presenter):
            let cell = tableView.dequeue(cellType: MainFormOrderDetailsTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .orderDetailsInsets
            return cell
        case let .savedCard(presenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .savedCardInsets
            return cell
        case let .getReceiptSwitch(presenter):
            let cell = tableView.dequeue(cellType: SwitchTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .getReceiptSwitchInsets
            return cell
        case let .email(presenter):
            let cell = tableView.dequeue(cellType: EmailTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .emailInsets
            return cell
        case let .payButton(presenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .payButtonInsets
            return cell
        case let .otherPaymentMethodsHeader(presenter):
            let cell = tableView.dequeue(cellType: TextHeaderCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .otherPaymentMethodsHeaderInsets
            return cell
        case let .otherPaymentMethod(paymentMethod):
            let cell = tableView.dequeue(cellType: AvatarTableViewCell.self, indexPath: indexPath)
            cell.update(with: .viewModel(from: paymentMethod))
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MainFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let orderDetailsInsets = UIEdgeInsets(top: 32, left: 16, bottom: 28, right: 16)
    static let savedCardInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    static let getReceiptSwitchInsets = UIEdgeInsets(top: .zero, left: 20, bottom: 12, right: 20)
    static let emailInsets = UIEdgeInsets(top: .zero, left: 16, bottom: 8, right: 16)
    static let payButtonInsets = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
    static let otherPaymentMethodsHeaderInsets = UIEdgeInsets(vertical: 12, horizontal: 16)
}

private extension CGRect {
    static let tableHeaderInitialFrame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 40))
}
