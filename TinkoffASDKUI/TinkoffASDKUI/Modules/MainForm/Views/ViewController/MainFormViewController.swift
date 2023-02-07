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

    private lazy var otherPaymentMethodsLabel: UILabel = {
        let label = UILabel()
        label.font = .headingMedium
        label.text = "Оплатить другим способом"
        label.textColor = ASDKColors.Text.primary.color
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.separatorStyle = .none
        tableView.register(ContainerTableViewCell.self, OtherPaymentMethodTableViewCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.dataSource = self
        tableView.delegate = self

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
        case .orderDetails:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(orderDetailsView, insets: .orderDetailsInsets)
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
        case .otherPaymentMethodsHeader:
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(otherPaymentMethodsLabel, insets: .otherPaymentMethodsHeader)
            return cell
        case let .otherPaymentMethod(paymentMethod):
            let cell = tableView.dequeue(cellType: OtherPaymentMethodTableViewCell.self, indexPath: indexPath)
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
    static let orderDetailsInsets = UIEdgeInsets(top: 32, left: 16, bottom: 24, right: 16)
    static let savedCardInsets = UIEdgeInsets(vertical: 8, horizontal: 16)
    static let payButtonInsets = UIEdgeInsets(top: 4, left: 16, bottom: 24, right: 16)
    static let otherPaymentMethodsHeader = UIEdgeInsets(vertical: 12, horizontal: 16)
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

    static var sbp: Button.Configuration {
        Button.Configuration(
            title: "Оплатить",
            image: .sbpImage,
            style: Button.Style(
                foregroundColor: Button.InteractiveColor(
                    normal: .white
                ),
                backgroundColor: Button.InteractiveColor(
                    normal: UIColor(hex: "#1D1346") ?? .clear
                )
            ),
            contentSize: modify(.basicLarge) { $0.imagePadding = 12 },
            imagePlacement: .trailing
        )
    }
}

// MARK: - OtherPaymentMethodViewModel + Helpers

extension OtherPaymentMethodViewModel {
    static func from(_ paymentMethod: MainFormPaymentMethod) -> OtherPaymentMethodViewModel {
        switch paymentMethod {
        case .card:
            return OtherPaymentMethodViewModel(
                title: "Картой",
                avatarImage: Asset.Icons.tinkoffPayIcon.image
            )
        case .tinkoffPay:
            return OtherPaymentMethodViewModel(
                title: "Tinkoff Pay",
                description: "В приложении Тинькофф",
                avatarImage: Asset.Icons.tinkoffPayIcon.image
            )
        case .sbp:
            return OtherPaymentMethodViewModel(
                title: "СБП",
                description: "В приложении любого банка",
                avatarImage: Asset.Icons.tinkoffPayIcon.image
            )
        }
    }
}

// MARK: - UIImage + Helpers

private extension UIImage {
    /// Извлекает иконку для светлой темы из динамического ассета
    static var sbpImage: UIImage {
        let imageAsset = UIImageAsset()
        let lightTraitCollection = UITraitCollection(userInterfaceStyle: .light)
        let lightImage = Asset.buttonIconSBP.image(compatibleWith: lightTraitCollection)

        imageAsset.register(
            lightImage,
            with: UITraitCollection(traitsFrom: [lightTraitCollection, UIScreen.main.traitCollection])
        )

        return imageAsset.image(with: UIScreen.main.traitCollection)
    }
}
