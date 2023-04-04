//
//  BuyProductsViewController.swift
//  ASDKSample
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import TinkoffASDKUI
import TinkoffASDKYandexPay
import UIKit

// swiftlint:disable file_length
class BuyProductsViewController: UIViewController {

    enum TableViewCellType {
        case products
        /// открыть экран оплаты и перейти к оплате
        case pay
        /// оплатить с помощью главной формы оплаты
        case mainFormPayment
        /// оплатить с карты - выбрать карту из списка и сделать этот платеж родительским
        case payAndSaveAsParent
        /// оплатить
        case payRequrent
        /// оплатить с помощью `Системы Быстрых Платежей`
        /// сгенерировать QR-код для оплаты
        case paySbpQrCode
        /// оплатить с помощью `Системы Быстрых Платежей`
        /// сгенерировать url для оплаты
        case paySbpUrl
        ///  Кнопка `YandexPay` с полным флоу оплаты (платеж инициируется из SDK)
        case yandexPayFull
        /// Кнопка `YandexPay` c завершающим флоу оплаты (платеж инициируется вне SDK)
        case yandexPayFinish
        /// Оплатить с помощью `TinkoffPay`
        case tinkoffPay
    }

    var products: [Product] = []
    var uiSDK: AcquiringUISDK!
    var coreSDK: AcquiringSdk!
    var customerKey: String!
    var customerEmail: String?

    lazy var selectedRebillCard: PaymentCard? = rebillCards.last
    private var rebillCards: [PaymentCard] { activeCards.filter { $0.parentPaymentId != nil } }
    private var activeCards = [PaymentCard]()

    private lazy var cardsController = uiSDK.cardsController(customerKey: customerKey)

    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonAddToCart: UIBarButtonItem!

    private var fullPaymentFlowYandexPayButton: IYandexPayButtonContainer?
    private var finishPaymentFlowYandexPayButton: IYandexPayButtonContainer?

    private var paymentData: PaymentInitData?
    private var tableViewCells: [TableViewCellType] = [
        .products,
        .pay,
        .mainFormPayment,
        .tinkoffPay,
        .payAndSaveAsParent,
        .payRequrent,
        .paySbpQrCode,
        .paySbpUrl,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.paymentSource

        tableView.registerCells(types: [ButtonTableViewCell.self])
        tableView.register(ContainerTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        updateCards()

        if products.count > 1 {
            buttonAddToCart.isEnabled = false
            buttonAddToCart.title = nil
        }

        setupYandexPayButton()
    }

    private func updateCards() {
        cardsController.getActiveCards { [weak self] result in
            switch result {
            case let .success(cards):
                self?.activeCards = cards
                self?.tableView.reloadData()
            case .failure:
                break
            }
        }
    }

    private func setupYandexPayButton() {
        let environment: YandexPaySDKConfiguration.Environment = {
            switch AppSetting.shared.serverType {
            case .prod, .custom: return .production
            case .test, .preProd: return .sandbox
            }
        }()

        let configuration = YandexPaySDKConfiguration(environment: environment, locale: .system)

        uiSDK.yandexPayButtonContainerFactory(with: configuration) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(factory):
                let configuration = YandexPayButtonContainerConfiguration(
                    theme: YandexPayButtonContainerTheme(appearance: .dark)
                )
                let fullPaymentButton = factory.createButtonContainer(with: configuration, delegate: self)
                self.fullPaymentFlowYandexPayButton = fullPaymentButton
                self.tableViewCells.append(.yandexPayFull)

                let finishPaymentButton = factory.createButtonContainer(with: configuration, delegate: self)
                self.finishPaymentFlowYandexPayButton = finishPaymentButton
                self.tableViewCells.append(.yandexPayFinish)
                self.tableView.reloadData()
            case .failure:
                break
            }
        }
    }

    @IBAction func addToCart(_ sender: Any) {
        if let product = products.first {
            CartDataProvider.shared.addProduct(product)
        }
    }

    private func selectRebuildCard() {
        guard let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "SelectRebuildCardViewController") as? SelectRebuildCardViewController,
            !rebillCards.isEmpty else {
            return
        }

        viewController.cards = rebillCards
        viewController.onSelectCard = { [weak self] card in
            guard let self = self else { return }

            self.selectedRebillCard = card
            if let index = self.tableViewCells.firstIndex(of: .payRequrent) {
                self.tableView.beginUpdates()
                self.tableView.reloadSections(IndexSet(integer: index), with: .fade)
                self.tableView.endUpdates()
            }
        }

        present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }

    private func productsAmount() -> Double {
        var amount: Double = 0

        products.forEach { product in
            amount += product.price.doubleValue
        }

        return amount
    }

    private func createPaymentData() -> PaymentInitData {
        let amount = productsAmount()
        let randomOrderId = String(Int64.random(in: 1000 ... 10000))
        var paymentData = PaymentInitData(amount: NSDecimalNumber(value: amount), orderId: randomOrderId, customerKey: customerKey)
        paymentData.description = "Краткое описние товара"

        var receiptItems: [Item] = []
        products.forEach { product in
            let item = Item(
                amount: product.price.int64Value * 100,
                price: product.price.int64Value * 100,
                name: product.name,
                tax: .vat10
            )
            receiptItems.append(item)
        }

        paymentData.receipt = Receipt(
            shopCode: nil,
            email: customerEmail,
            taxation: .osn,
            phone: "+79876543210",
            items: receiptItems,
            agentData: nil,
            supplierInfo: nil,
            customer: nil,
            customerInn: nil
        )

        return paymentData
    }

    func payAndSaveAsParent() {
        var paymentData = createPaymentData()
        paymentData.savingAsParentPayment = true

        let paymentOptions = PaymentOptions.create(from: paymentData)
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        let configuration = MainFormUIConfiguration(
            orderDescription: paymentOptions.orderOptions.description
        )

        uiSDK.presentMainForm(
            on: self,
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: nil
        ) { [weak self] result in
            self?.showAlert(with: result)
        }
    }

    func charge(_ complete: @escaping (() -> Void)) {
        if let parentPaymentId = selectedRebillCard?.parentPaymentId {

            let paymentOptions = PaymentOptions.create(from: createPaymentData())
            let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)
            let amount = paymentOptions.orderOptions.amount

            uiSDK.presentRecurrentPayment(
                on: self,
                paymentFlow: paymentFlow,
                amount: amount,
                rebillId: String(parentPaymentId),
                failureDelegate: self
            ) { [weak self] result in
                complete()
                self?.showAlert(with: result)
            }
        }
    }

    func generateSbpQrImage() {
        let paymentOptions = PaymentOptions.create(from: createPaymentData())
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        uiSDK.presentDynamicQr(on: self, paymentFlow: paymentFlow) { [weak self] result in
            self?.showAlert(with: result)
        }
    }

    func generateSbpUrl() {
        let paymentOptions = PaymentOptions.create(from: createPaymentData())
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        uiSDK.presentSBPBanksList(on: self, paymentFlow: paymentFlow) { [weak self] result in
            self?.showAlert(with: result)
        }
    }

    private func payWithMainForm() {
        let paymentOptions = PaymentOptions.create(from: createPaymentData())
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        let configuration = MainFormUIConfiguration(
            orderDescription: paymentOptions.orderOptions.description
        )

        uiSDK.presentMainForm(
            on: self,
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: self
        ) { [weak self] result in
            self?.showAlert(with: result)
        }
    }

    private func payWithTinkoffPay() {
        let paymentOptions = PaymentOptions.create(from: createPaymentData())
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        uiSDK.presentTinkoffPay(on: self, paymentFlow: paymentFlow) { [weak self] result in
            self?.showAlert(with: result)
        }
    }

    private func showAlert(with result: PaymentResult) {
        let alert = UIAlertController(
            title: result.alertTitle,
            message: result.alertMessage,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: Loc.Button.ok, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension BuyProductsViewController: ICardScannerDelegate {
    func cardScanButtonDidPressed(on viewController: UIViewController, completion: @escaping CardScannerCompletion) {
        let alert = UIAlertController.cardScannerMock(confirmationHandler: completion)
        viewController.present(alert, animated: true)
    }
}

extension BuyProductsViewController: IRecurrentPaymentFailiureDelegate {
    func recurrentPaymentNeedRepeatInit(additionalData: [String: String], completion: @escaping (Result<PaymentId, Error>) -> Void) {
        guard var initData = paymentData else { return }

        let newPaymentData = initData.paymentFormData?.merging(additionalData) { $1 }
        initData.paymentFormData = newPaymentData

        coreSDK.initPayment(data: initData) { result in
            if let paymentId = try? result.map({ $0.paymentId }).get() {
                completion(.success(paymentId))
            }
        }
    }
}

extension BuyProductsViewController: UITableViewDataSource {

    // MARK: UITableViewDataSource

    private func yellowButtonColor() -> UIColor {
        return UIColor(red: 1, green: 0.867, blue: 0.176, alpha: 1)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCells.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewCells[section] {
        case .products: return products.count
        case .payRequrent: return rebillCards.count > 0 ? 2 : 1
        default: return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewCells[indexPath.section] {
        case .products:
            let cell = tableView.defaultCell()
            let product = products[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = Utils.formatAmount(product.price)
            return cell

        case .pay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(Loc.Button.pay, for: .normal)
                cell.button.isEnabled = true
                cell.button.backgroundColor = yellowButtonColor()
                cell.button.setImage(nil, for: .normal)
                cell.onButtonTouch = {}
                return cell
            }
        case .mainFormPayment:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell else { break }
            cell.button.setTitle(Loc.Button.pay, for: .normal)
            cell.button.backgroundColor = yellowButtonColor()
            cell.button.setImage(nil, for: .normal)
            cell.onButtonTouch = { [weak self] in self?.payWithMainForm() }
            return cell
        case .payAndSaveAsParent:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(Loc.Button.pay, for: .normal)
                cell.button.isEnabled = true
                cell.button.backgroundColor = yellowButtonColor()
                cell.button.setImage(nil, for: .normal)
                cell.onButtonTouch = { [weak self] in
                    self?.payAndSaveAsParent()
                }

                return cell
            }

        case .payRequrent:
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                    cell.button.setTitle(Loc.Button.paymentTryAgain, for: .normal)
                    cell.button.backgroundColor = yellowButtonColor()
                    cell.button.setImage(nil, for: .normal)

                    cell.button.isEnabled = true

                    cell.onButtonTouch = { [weak self, weak cell] in
                        cell?.activityIndicator.startAnimating()
                        cell?.button.isEnabled = false
                        self?.charge {
                            cell?.activityIndicator.stopAnimating()
                            cell?.button.isEnabled = true
                        }
                    }

                    return cell
                }
            } else {
                let cell = tableView.defaultCell()
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = Loc.Button.selectAnotherCard
                cell.detailTextLabel?.text = nil
                return cell
            }

        case .paySbpQrCode:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(nil, for: .normal)
                cell.button.backgroundColor = .clear
                cell.button.isEnabled = AppSetting.shared.paySBP
                cell.button.setImage(Asset.logoSbp.image, for: .normal)
                cell.onButtonTouch = { [weak self] in
                    self?.generateSbpQrImage()
                }

                return cell
            }

        case .paySbpUrl:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(nil, for: .normal)
                cell.button.backgroundColor = .clear
                cell.button.isEnabled = AppSetting.shared.paySBP
                cell.button.setImage(Asset.logoSbp.image, for: .normal)
                cell.onButtonTouch = { [weak self] in
                    self?.generateSbpUrl()
                }

                return cell
            }
        case .yandexPayFull:
            let cell = tableView.dequeue(ContainerTableViewCell.self)
            if let button = fullPaymentFlowYandexPayButton {
                cell.setContent(button, insets: UIEdgeInsets(horizontal: 32, vertical: 8))
            }
            return cell
        case .yandexPayFinish:
            let cell = tableView.dequeue(ContainerTableViewCell.self)
            if let button = finishPaymentFlowYandexPayButton {
                cell.setContent(button, insets: UIEdgeInsets(horizontal: 64, vertical: 8))
            }
            return cell
        case .tinkoffPay:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell else { break }
            cell.button.setTitle("Tinkoff Pay", for: .normal)
            cell.button.backgroundColor = yellowButtonColor()
            cell.button.setImage(nil, for: .normal)
            cell.onButtonTouch = { [weak self] in self?.payWithTinkoffPay() }
            return cell
        }

        return tableView.defaultCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableViewCells[section] {
        case .products:
            return Loc.Title.goods
        case .pay:
            return Loc.Title.paymeny
        case .mainFormPayment:
            return Loc.Title.paymeny
        case .payAndSaveAsParent:
            return Loc.Title.payAndSaveAsParent
        case .payRequrent:
            return Loc.Title.paymentTryAgain
        case .paySbpUrl, .paySbpQrCode:
            return Loc.Title.payBySBP
        case .yandexPayFull, .yandexPayFinish:
            return Loc.Title.yandexPay
        case .tinkoffPay:
            return "Оплатить с помощью Tinkoff Pay"
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch tableViewCells[section] {
        case .products:
            return "сумма: \(Utils.formatAmount(NSDecimalNumber(value: productsAmount())))"

        case .pay:
            let cardsCount = activeCards.count
            if cardsCount > 0 {
                return "открыть платежную форму и перейти к оплате товара, доступно \(cardsCount) сохраненных карт"
            }

            return "открыть платежную форму и перейти к оплате товара"
        case .mainFormPayment:
            return "Открыть главную платежную форму и перейти к оплате товара"
        case .payAndSaveAsParent:
            let cardsCount = activeCards.count
            if cardsCount > 0 {
                return "открыть платежную форму и перейти к оплате товара. При удачной оплате этот платеж сохраниться как родительский. Доступно \(cardsCount) сохраненных карт"
            }

            return "оплатить и сделать этот платеж родительским"
        case .payRequrent:
            if let card = selectedRebillCard, let parentPaymentId = card.parentPaymentId {
                return "оплатить с карты \(card.pan) \(card.expDateFormat() ?? ""), используя родительский платеж \(parentPaymentId)"
            }

            return "нет доступных родительских платежей"

        case .paySbpUrl:
            return "сгенерировать url и открыть диалог для выбора приложения для оплаты"
        case .paySbpQrCode:
            return "сгенерировать QR-код для оплаты и показать его на экране, для сканирования и оплаты другим смартфоном"
        case .yandexPayFull:
            return "Full payment flow"
        case .yandexPayFinish:
            return "Finish payment flow"
        case .tinkoffPay:
            return "Открыть экран Tinkoff Pay и начать платеж"
        }
    }
}

extension BuyProductsViewController: UITableViewDelegate {

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch tableViewCells[indexPath.section] {
        case .payRequrent:
            selectRebuildCard()

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {}
}

// MARK: - IYandexPayButtonContainerDelegate

extension BuyProductsViewController: YandexPayButtonContainerDelegate {
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didRequestPaymentSheet completion: @escaping (YandexPayPaymentSheet?) -> Void
    ) {
        let paymentData = createPaymentData()
        self.paymentData = paymentData

        let order = YandexPayPaymentSheet.Order(
            orderId: paymentData.orderId,
            amount: paymentData.amount
        )

        let paymentSheet = YandexPayPaymentSheet(order: order)

        completion(paymentSheet)
    }

    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didRequestPaymentFlow completion: @escaping (PaymentFlow?) -> Void
    ) {
        guard let initData = paymentData else { return }

        switch container {
        case fullPaymentFlowYandexPayButton as UIView?:
            completion(.full(paymentOptions: .create(from: initData)))

        case finishPaymentFlowYandexPayButton as UIView?:
            container.setLoaderVisible(true, animated: true)

            coreSDK.initPayment(data: initData) { [weak container] result in
                DispatchQueue.main.async {
                    container?.setLoaderVisible(false, animated: true)
                }

                let customerOptions = initData.customerKey.map {
                    CustomerOptions(customerKey: $0, email: "exampleEmail@tinkoff.ru")
                }

                let paymentFlow: PaymentFlow? = try? result.map { payload in
                    let paymentOptions = FinishPaymentOptions(
                        paymentId: payload.paymentId,
                        amount: payload.amount,
                        orderId: payload.orderId,
                        customerOptions: customerOptions
                    )
                    return PaymentFlow.finish(paymentOptions: paymentOptions)
                }.get()

                completion(paymentFlow)
            }
        default:
            break
        }
    }

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController? {
        self
    }

    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: PaymentResult
    ) {
        showAlert(with: result)
    }
}

// MARK: - PaymentOptions + PaymentInitData

private extension PaymentOptions {
    static func create(from initData: PaymentInitData) -> PaymentOptions {
        let orderOptions = OrderOptions(
            orderId: initData.orderId,
            amount: initData.amount,
            description: initData.description,
            receipt: initData.receipt,
            shops: initData.shops,
            receipts: initData.receipts,
            savingAsParentPayment: initData.savingAsParentPayment ?? false
        )

        let customerOptions = initData.customerKey.map {
            CustomerOptions(customerKey: $0, email: "exampleEmail@tinkoff.ru")
        }

        return PaymentOptions(
            orderOptions: orderOptions,
            customerOptions: customerOptions,
            paymentData: initData.paymentFormData ?? [:]
        )
    }
}

// MARK: - PaymentResult + Helpers

extension PaymentResult {
    var alertTitle: String {
        switch self {
        case .succeeded:
            return "Payment was successful"
        case .failed:
            return "An error occurred during payment"
        case .cancelled:
            return "Payment canceled by user"
        }
    }

    var alertMessage: String {
        switch self {
        case let .succeeded(paymentInfo):
            return "\(paymentInfo)"
        case let .failed(error):
            return "\(error)"
        case let .cancelled(paymentInfo):
            return paymentInfo.map { "\($0)" } ?? ""
        }
    }
}
