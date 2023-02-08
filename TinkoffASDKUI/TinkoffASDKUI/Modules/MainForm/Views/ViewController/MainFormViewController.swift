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
    private lazy var payButton = Button { [presenter] in presenter.viewDidTapPayButton() }
    private lazy var otherPaymentMethodsHeader = UILabel()

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
        setupOtherPaymentMethodsHeader()
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
        tableView.register(
            MainFormOrderDetailsTableCell.self,
            SavedCardTableCell.self,
            SwitchTableCell.self,
            EmailTableCell.self,
            ContainerTableViewCell.self,
            AvatarTableViewCell.self
        )
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupOtherPaymentMethodsHeader() {
        otherPaymentMethodsHeader.font = .headingMedium
        otherPaymentMethodsHeader.textColor = ASDKColors.Text.primary.color
        otherPaymentMethodsHeader.text = "Оплатить другим способом"
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func setButtonPrimaryAppearance() {
        payButton.configure(.cardPayment)
    }

    func setButtonTinkoffPayAppearance() {
        payButton.configure(.tinkoffPay)
    }

    func setButtonSBPAppearance() {
        payButton.configure(.sbp)
    }

    func setButtonEnabled(_ enabled: Bool) {
        payButton.isEnabled = enabled
    }

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
        case .payButton:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(payButton, insets: .payButtonInsets)
            return cell
        case .otherPaymentMethodsHeader:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(otherPaymentMethodsHeader, insets: .otherPaymentMethodsHeader)
            return cell
        case let .otherPaymentMethod(paymentMethod):
            let cell = tableView.dequeue(cellType: AvatarTableViewCell.self, indexPath: indexPath)
            cell.update(with: .from(paymentMethod))
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
    static let savedCardInsets = UIEdgeInsets(vertical: 8, horizontal: 16)
    static let getReceiptSwitchInsets = UIEdgeInsets(vertical: 8, horizontal: 20)
    static let emailInsets = UIEdgeInsets(top: 4, left: 16, bottom: 8, right: 16)
    static let payButtonInsets = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
    static let otherPaymentMethodsHeader = UIEdgeInsets(vertical: 12, horizontal: 16)
}

private extension CGRect {
    static let tableHeaderInitialFrame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 40))
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
            image: Asset.TinkoffPay.tinkoffPaySmallNoBorder.image,
            style: .primaryTinkoff,
            contentSize: .basicLarge,
            imagePlacement: .trailing
        )
    }

    // Кнопка СБП не может быть в состоянии disabled, поэтому корректные цвета для этого не заданы.
    // Если появится необходимость, попросить дизайнера отрисовать это состояние, а затем положить цвет в `Button.Style`
    static var sbp: Button.Configuration {
        Button.Configuration(
            title: "Оплатить",
            image: Asset.Sbp.sbpLogoLight.image,
            style: Button.Style(
                foregroundColor: Button.InteractiveColor(normal: .white),
                backgroundColor: Button.InteractiveColor(normal: UIColor(hex: "#1D1346") ?? .clear)
            ),
            contentSize: modify(.basicLarge) { $0.imagePadding = 12 },
            imagePlacement: .trailing
        )
    }
}

// MARK: - AvatarTableViewCellModel + Helpers

private extension AvatarTableViewCellModel {
    static func from(_ paymentMethod: MainFormPaymentMethod) -> AvatarTableViewCellModel {
        switch paymentMethod {
        case .card:
            return AvatarTableViewCellModel(
                title: "Картой",
                avatarImage: Asset.PaymentCard.cardFrontsideAvatar.image
            )
        case .tinkoffPay:
            return AvatarTableViewCellModel(
                title: "Tinkoff Pay",
                description: "В приложении Тинькофф",
                avatarImage: Asset.TinkoffPay.tinkoffPayAvatar.image
            )
        case .sbp:
            return AvatarTableViewCellModel(
                title: "СБП",
                description: "В приложении любого банка",
                avatarImage: Asset.Sbp.sbpAvatar.image
            )
        }
    }
}
