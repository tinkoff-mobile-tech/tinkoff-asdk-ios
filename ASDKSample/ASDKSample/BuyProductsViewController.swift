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

import PassKit
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
        /// оплатить с карты - выбрать карту из списка и сделать этот платеж родительским
        case payAndSaveAsParent
        /// оплатить
        case payRequrent
        /// оплатить с помощью `ApplePay`
        case payApplePay
        /// оплатить с помощью `Системы Быстрых Платежей`
        /// сгенерировать QR-код для оплаты
        case paySbpQrCode
        /// оплатить с помощью `Системы Быстрых Платежей`
        /// сгенерировать url для оплаты
        case paySbpUrl
        /// Оплатить с помощью встроенной кнопки `YandexPay`
        case yandexPay
    }

    var products: [Product] = []
    var uiSDK: AcquiringUISDK!
    var coreSDK: AcquiringSdk!
    var customerKey: String!
    var customerEmail: String?
    weak var scaner: AcquiringScanerProtocol?

    lazy var paymentApplePayConfiguration = AcquiringUISDK.ApplePayConfiguration()
    var paymentCardId: PaymentCard?
    var paymentCardParentPaymentId: PaymentCard?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonAddToCart: UIBarButtonItem!
    private lazy var yandexPayButtonContainerView = YPButtonContainerView()

    private var paymentData: PaymentInitData?
    private var cardRebillIds: [PaymentCard]?
    private var tableViewCells: [TableViewCellType] = [
        .products,
        .pay,
        .payAndSaveAsParent,
        .payRequrent,
        .payApplePay,
        .paySbpQrCode,
        .paySbpUrl,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.paymentSource

        tableView.registerCells(types: [ButtonTableViewCell.self])
        tableView.register(ContainerTableViewCell.self, forCellReuseIdentifier: ContainerTableViewCell.reusableId)
        tableView.delegate = self
        tableView.dataSource = self

        uiSDK.setupCardListDataProvider(for: customerKey, statusListener: self)
        try? uiSDK.cardListReloadData()
        uiSDK.addCardNeedSetCheckTypeHandler = {
            AppSetting.shared.addCardChekType
        }

        if products.count > 1 {
            buttonAddToCart.isEnabled = false
            buttonAddToCart.title = nil
        }

        setupYandexPayButton()
    }

    private func setupYandexPayButton() {
        let configuration = YandexPaySDKConfiguration(environment: .sandbox, locale: .system)

        uiSDK.yandexPayButtonContainerFactory(with: configuration) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(factory):
                let button = factory.createButtonContainer(
                    with: YandexPayButtonContainerConfiguration(theme: YandexPayButtonContainerTheme(appearance: .dark)),
                    delegate: self
                )

                self.yandexPayButtonContainerView.set(button: button)
                self.tableViewCells.append(.yandexPay)
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
            let cards: [PaymentCard] = cardRebillIds,
            !cards.isEmpty else {
            return
        }

        viewController.cards = cards
        viewController.onSelectCard = { card in
            self.paymentCardParentPaymentId = card
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

    private func acquiringViewConfiguration() -> AcquiringViewConfiguration {
        let viewConfigration = AcquiringViewConfiguration()
        viewConfigration.scaner = scaner
        viewConfigration.tinkoffPayButtonStyle = TinkoffPayButton.DynamicStyle(lightStyle: .whiteBordered, darkStyle: .blackBordered)

        viewConfigration.fields = []
        // InfoFields.amount
        let title = NSAttributedString(
            string: Loc.Title.paymeny,

            attributes: [.font: UIFont.boldSystemFont(ofSize: 22)]
        )
        // swiftlint:disable:next compiler_protocol_init
        let amountString = Utils.formatAmount(NSDecimalNumber(floatLiteral: productsAmount()))

        let amountTitle = NSAttributedString(
            string: "\(Loc.Text.totalAmount) \(amountString)",

            attributes: [.font: UIFont.systemFont(ofSize: 17)]
        )
        // fields.append
        viewConfigration.fields.append(AcquiringViewConfiguration.InfoFields.amount(title: title, amount: amountTitle))

        // InfoFields.detail
        let productsDetatils = NSMutableAttributedString()
        productsDetatils.append(NSAttributedString(string: "Книги\n", attributes: [.font: UIFont.systemFont(ofSize: 17)]))

        let productsDetails = products.map { $0.name }.joined(separator: ", ")
        let detailsFieldTitle = NSAttributedString(
            string: productsDetails,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor(red: 0.573, green: 0.6, blue: 0.635, alpha: 1),
            ]
        )
        viewConfigration.fields.append(AcquiringViewConfiguration.InfoFields.detail(title: detailsFieldTitle))

        if AppSetting.shared.showEmailField {
            let emailField = AcquiringViewConfiguration.InfoFields.email(
                value: nil,
                placeholder: Loc.Plaseholder.email
            )
            viewConfigration.fields.append(emailField)
        }

        viewConfigration.featuresOptions.fpsEnabled = AppSetting.shared.paySBP
        viewConfigration.featuresOptions.tinkoffPayEnabled = AppSetting.shared.tinkoffPay

        viewConfigration.viewTitle = Loc.Title.pay
        viewConfigration.localizableInfo = AcquiringViewConfiguration.LocalizableInfo(lang: AppSetting.shared.languageId)

        return viewConfigration
    }

    private func responseReviewing(_ response: Result<PaymentStatusResponse, Error>) {
        switch response {
        case let .success(result):
            var message = Loc.Text.paymentStatusAmount
            message.append(" \(Utils.formatAmount(result.amount)) ")

            if result.status == .cancelled {
                message.append(Loc.Text.paymentStatusCancel)
            } else {
                message.append(" ")
                message.append(Loc.Text.paymentStatusSuccess)
                message.append("\npaymentId = \(result.paymentId)")
            }

            if AppSetting.shared.acquiring {
                uiSDK.presentAlertView(on: self, title: message, icon: result.status == .cancelled ? .error : .success)
            } else {
                let alertView = UIAlertController(title: "Tinkoff Acquaring", message: message, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: Loc.Button.ok, style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
            }

        case let .failure(error):
            if AppSetting.shared.acquiring {
                uiSDK.presentAlertView(on: self, title: error.localizedDescription, icon: .error)
            } else {
                let alertView = UIAlertController(title: "Tinkoff Acquaring", message: error.localizedDescription, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: Loc.Button.ok, style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
            }
        }
    }

    private func presentPaymentView(paymentData: PaymentInitData, viewConfigration: AcquiringViewConfiguration) {
        uiSDK.presentPaymentView(
            on: self,
            acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration(
                paymentStage: .`init`(paymentData: paymentData)
            ),
            configuration: viewConfigration,
            tinkoffPayDelegate: nil
        ) { [weak self] response in
            self?.responseReviewing(response)
        }
    }

    func pay() {
        presentPaymentView(paymentData: createPaymentData(), viewConfigration: acquiringViewConfiguration())
    }

    func pay(_ complete: @escaping (() -> Void)) {
        uiSDK.pay(
            on: self,
            initPaymentData: createPaymentData(),
            cardRequisites: PaymentSourceData.cardNumber(number: "!!!номер карты!!!", expDate: "1120", cvv: "111"),
            infoEmail: nil,
            configuration: acquiringViewConfiguration()
        ) { [weak self] response in
            complete()
            self?.responseReviewing(response)
        }
    }

    func payByApplePay() {

        let paymentData = createPaymentData()

        let request = PKPaymentRequest()
        request.merchantIdentifier = paymentApplePayConfiguration.merchantIdentifier
        request.supportedNetworks = paymentApplePayConfiguration.supportedNetworks
        request.merchantCapabilities = paymentApplePayConfiguration.capabilties
        request.countryCode = paymentApplePayConfiguration.countryCode
        request.currencyCode = paymentApplePayConfiguration.currencyCode
        request.shippingContact = paymentApplePayConfiguration.shippingContact
        request.billingContact = paymentApplePayConfiguration.billingContact

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: paymentData.description ?? "",
                amount: NSDecimalNumber(value: Double(paymentData.amount) / Double(100.0))
            ),
        ]

        guard let viewController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            return
        }

        viewController.delegate = self

        present(viewController, animated: true, completion: nil)
    }

    func payAndSaveAsParent() {
        var paymentData = createPaymentData()
        paymentData.savingAsParentPayment = true

        presentPaymentView(paymentData: paymentData, viewConfigration: acquiringViewConfiguration())
    }

    func charge(_ complete: @escaping (() -> Void)) {
        if let parentPaymentId = paymentCardParentPaymentId?.parentPaymentId {
            uiSDK.presentPaymentView(
                on: self,
                paymentData: createPaymentData(),
                parentPatmentId: parentPaymentId,
                configuration: acquiringViewConfiguration()
            ) { [weak self] response in
                complete()
                self?.responseReviewing(response)
            }
        }
    }

    func generateSbpQrImage() {
        uiSDK.presentPaymentSbpQrImage(
            on: self,
            paymentData: createPaymentData(),
            configuration: acquiringViewConfiguration()
        ) { [weak self] response in
            self?.responseReviewing(response)
        }
    }

    func generateSbpUrl() {
        let acquiringPaymentStageConfiguration = AcquiringPaymentStageConfiguration(
            paymentStage: .`init`(paymentData: createPaymentData())
        )
        let viewController = uiSDK.urlSBPPaymentViewController(
            acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
            configuration: acquiringViewConfiguration()
        )
        present(viewController, animated: true, completion: nil)
    }
}

extension BuyProductsViewController: CardListDataSourceStatusListener {

    // MARK: CardListDataSourceStatusListener

    func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>) {
        switch status {
        case let .object(cards):
            if paymentCardId == nil {
                paymentCardId = cards.first
            }

            cardRebillIds = cards.filter { card -> Bool in
                card.parentPaymentId != nil
            }

            if paymentCardParentPaymentId == nil {
                paymentCardParentPaymentId = cards.last(where: { card -> Bool in
                    card.parentPaymentId != nil
                })
            }

        default:
            break
        }

        tableView.reloadData()
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
        var result = 1

        switch tableViewCells[section] {
        case .products:
            result = products.count

        case .payRequrent:
            if cardRebillIds?.count ?? 0 > 0 {
                result = 2
            }

        default:
            result = 1
        }

        return result
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
                // открыть экран оплаты и оплатить
                cell.onButtonTouch = { [weak self] in
                    self?.pay()
                }
                // оплатить в один клик, не показывая экран оплаты
                // cell.onButtonTouch = { [weak self, weak cell] in
                //	cell?.activityIndicator.startAnimating()
                //	cell?.button.isEnabled = false
                //	self?.pay {
                //		cell?.activityIndicator.stopAnimating()
                //		cell?.button.isEnabled = true
                //	}
                // }

                return cell
            }

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
                    if let card = paymentCardParentPaymentId {
                        cell.button.isEnabled = (card.parentPaymentId != nil)
                    } else {
                        cell.button.isEnabled = false
                    }

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

        case .payApplePay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(nil, for: .normal)
                cell.button.backgroundColor = .clear
                cell.button.setImage(Asset.buttonApplePay.image, for: .normal)
                cell.button.isEnabled = uiSDK.canMakePaymentsApplePay(with: paymentApplePayConfiguration)

                cell.onButtonTouch = { [weak self] in
                    self?.payByApplePay()
                }

                return cell
            }

        case .paySbpQrCode:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.nibName) as? ButtonTableViewCell {
                cell.button.setTitle(nil, for: .normal)
                cell.button.backgroundColor = .clear
                cell.button.isEnabled = uiSDK.canMakePaymentsSBP()
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
                cell.button.isEnabled = uiSDK.canMakePaymentsSBP()
                cell.button.setImage(Asset.logoSbp.image, for: .normal)
                cell.onButtonTouch = { [weak self] in
                    self?.generateSbpUrl()
                }

                return cell
            }
        case .yandexPay:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContainerTableViewCell.reusableId) as? ContainerTableViewCell else {
                fatalError()
            }
            cell.setContent(yandexPayButtonContainerView)
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

        case .payAndSaveAsParent:
            return Loc.Title.payAndSaveAsParent

        case .payRequrent:
            return Loc.Title.paymentTryAgain

        case .payApplePay:
            return Loc.Title.payByApplePay

        case .paySbpUrl, .paySbpQrCode:
            return Loc.Title.payBySBP
        case .yandexPay:
            return Loc.Title.yandexPay
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch tableViewCells[section] {
        case .products:
            return "сумма: \(Utils.formatAmount(NSDecimalNumber(value: productsAmount())))"

        case .pay:
            let cardsCount = (try? uiSDK.cardListNumberOfCards()) ?? 0
            if cardsCount > 0 {
                return "открыть платежную форму и перейти к оплате товара, доступно \(cardsCount) сохраненных карт"
            }

            return "открыть платежную форму и перейти к оплате товара"
        case .payAndSaveAsParent:
            let cardsCount = (try? uiSDK.cardListNumberOfCards()) ?? 0
            if cardsCount > 0 {
                return "открыть платежную форму и перейти к оплате товара. При удачной оплате этот платеж сохраниться как родительский. Доступно \(cardsCount) сохраненных карт"
            }

            return "оплатить и сделать этот платеж родительским"
        case .payRequrent:
            if let card = paymentCardParentPaymentId, let parentPaymentId = card.parentPaymentId {
                return "оплатить с карты \(card.pan) \(card.expDateFormat() ?? ""), используя родительский платеж \(parentPaymentId)"
            }

            return "нет доступных родительских платежей"

        case .payApplePay:
            if uiSDK.canMakePaymentsApplePay(with: paymentApplePayConfiguration) {
                return "оплатить с помощью ApplePay"
            }

            return "оплата с помощью ApplePay недоступна"

        case .paySbpUrl:
            if uiSDK.canMakePaymentsSBP() {
                return "сгенерировать url и открыть диалог для выбора приложения для оплаты"
            }

            return "оплата недоступна"

        case .paySbpQrCode:
            if uiSDK.canMakePaymentsSBP() {
                return "сгенерировать QR-код для оплаты и показать его на экране, для сканирования и оплаты другим смартфоном"
            }

            return "оплата недоступна"
        case .yandexPay:
            return nil
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

extension BuyProductsViewController: PKPaymentAuthorizationViewControllerDelegate {

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        let initData = createPaymentData()
        uiSDK.performPaymentWithApplePay(
            paymentData: initData,
            paymentToken: payment.token,
            acquiringConfiguration: AcquiringConfiguration(paymentStage: .none)
        ) { result in
            switch result {
            case let .failure(error):
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            case .success:
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            }
        }
    }
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
        let paymentFlow: PaymentFlow? = paymentData.map { paymentData in
            let orderOptions = OrderOptions(
                orderId: paymentData.orderId,
                amount: paymentData.amount,
                description: paymentData.description,
                receipt: paymentData.receipt,
                shops: paymentData.shops,
                receipts: paymentData.receipts,
                savingAsParentPayment: paymentData.savingAsParentPayment ?? false
            )

            let customerOptions = paymentData.customerKey.map {
                CustomerOptions(customerKey: $0, email: "exampleEmail@tinkoff.ru")
            }

            let paymentOptions = PaymentOptions(
                orderOptions: orderOptions,
                customerOptions: customerOptions,
                paymentData: ["PaymentFlowType": "Full"]
            )

            return .full(paymentOptions: paymentOptions)
        }

        completion(paymentFlow)
    }

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController? {
        self
    }

    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: YandexPayPaymentResult
    ) {
        let message: String = {
            switch result {
            case .cancelled:
                return "\(Loc.Text.payment) \(Loc.Text.paymentStatusCancel)"
            case let .succeeded(info):
                return "\(Loc.Text.paymentStatusAmount) \(info.amount) \(Loc.Text.paymentStatusSuccess)"
            case let .failed(error):
                return "\(error)"
            }
        }()

        let alert = UIAlertController(
            title: "YandexPay",
            message: message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: Loc.Button.ok, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
