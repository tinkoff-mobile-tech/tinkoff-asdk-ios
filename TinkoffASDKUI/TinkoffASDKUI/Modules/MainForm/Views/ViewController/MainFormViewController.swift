//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormViewController: UIViewController, PullableContainerScrollableContent {

    // MARK: PullableContainer Properties

    var scrollView: UIScrollView { tableView }
    var pullableContainerContentHeight: CGFloat { 650 }
    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    // MARK: Dependencies

    private let presenter: IMainFormPresenter

    // MARK: Subviews

    private lazy var headerView = MainFormHeaderView(frame: .headerInitialFrame)
    private lazy var orderDetailsView = MainFormOrderDetailsView()
    private lazy var savedCardView = SavedCardView()
    private lazy var payButton = Button { [presenter] in presenter.viewDidTapPayButton() }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.separatorStyle = .none
        tableView.register(ContainerTableViewCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.dataSource = self

        return tableView
    }()

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
        tableView.tableHeaderView = headerView
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func updateOrderDetails(with model: MainFormOrderDetailsViewModel) {
        orderDetailsView.update(with: model)
    }

    func set(payButtonEnabled: Bool) {
        payButton.isEnabled = payButtonEnabled
    }

    func setButtonPrimaryAppearance() {
        payButton.configure(.tinkoffPay)
    }

    func setButtonTinkoffPayAppearance() {
        payButton.configure(.tinkoffPay)
    }

    func setButtonSBPAppearance() {}

    func setPayButtonPrimaryStyle() {}
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
        let cellType = presenter.row(at: indexPath)

        switch cellType {
        case .orderDetails:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(orderDetailsView, insets: .zero)
            return cell
        case let .savedCard(savedCardPresenter):
            savedCardView.presenter = savedCardPresenter
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(savedCardView, insets: .savedCardInsets)
            return cell
        case .payButton:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(payButton, insets: .payButtonInsets)
            return cell
        }
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let savedCardInsets = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
    static let payButtonInsets = UIEdgeInsets(vertical: 16, horizontal: 16)
}

private extension CGRect {
    static let headerInitialFrame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 40))
}

// MARK: - Button.Configuration + Helpers

private extension Button.Configuration {
    static var cardPayment: Button.Configuration {
        Button.Configuration(
            title: "Оплатить",
            style: .primaryTinkoff,
            contentSize: .basicLarge
        )
    }

    static var tinkoffPay: Button.Configuration {
        Button.Configuration(
            title: "Оплатить с Тинькофф",
            image: Asset.Icons.tinkoffPayIcon.image,
            style: .primaryTinkoff,
            contentSize: .basicLarge,
            imagePlacement: .trailing
        )
    }
}
