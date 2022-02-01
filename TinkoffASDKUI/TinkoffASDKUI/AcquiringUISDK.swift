//
//  AcquiringUISDK.swift
//  TinkoffASDKUI
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
import UIKit
import WebKit

public class AcquiringViewConfiguration {
    ///
    /// Поля на форме оплаты
    public enum InfoFields {
        /// Информация о товаре, заголовок и цена
        case amount(title: NSAttributedString, amount: NSAttributedString)
        /// описание товара
        case detail(title: NSAttributedString)
        /// поле ввода email, куда выслать чек - результат оплаты
        case email(value: String?, placeholder: String)
        /// показывать кнопку оплаты Системы Быстрых Платежей
        case buttonPaySPB
    }

    public struct FeaturesOptions {
        var fpsEnabled: Bool = false

        init() {}
    }

    ///
    /// Локализация формы оплаты
    public struct LocalizableInfo {
        var table: String?
        var bundle: Bundle?
        var lang: String?

        public init(lang: String?) {
            self.lang = lang
        }

        public init(table: String?, bundle: Bundle?) {
            self.table = table
            self.bundle = bundle
        }
    }

    public var localizableInfo: LocalizableInfo?

    ///  Сканер
    public weak var scaner: AcquiringScanerProtocol?
    ///
    public weak var alertViewHelper: AcquiringAlertViewProtocol?
    public var alertViewEnable: Bool = true
    public var featuresOptions = FeaturesOptions()
    public var fields: [InfoFields] = []
    public var viewTitle: String?
    public var startViewHeight: CGFloat?

    public init() {}
}

public struct AcquiringConfiguration {
    public enum PaymentStage {
        case none
        case paymentId(PaymentId)
    }

    public let paymentStage: PaymentStage

    public init(paymentStage: PaymentStage = .none) {
        self.paymentStage = paymentStage
    }
}

public typealias PaymentCompletionHandler = ((_ result: Result<GetPaymentStatePayload, Error>) -> Void)
public typealias AddCardCompletionHandler = ((_ result: Result<AddCardStatusResponse, Error>) -> Void)

/// Сканер для реквизитов карты
public protocol AcquiringScanerProtocol: class {
    ///
    /// - Parameters:
    ///   - completion: результат сканирования, номер карты `number`, год `yy`, месяц `mm`
    /// - Returns: сканер UIViewController
    func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController?
}

/// Отображение не стандартного AlertView если в приложении используется не UIAlertController
public protocol AcquiringAlertViewProtocol: class {
    ///
    /// - Parameters:
    ///   - title: заголовок
    ///   - message: описание
    ///   - completion: блок для уведомления что алерт закрыли
    /// - Returns: алерт UIViewController
    func presentAlertView(_ title: String?, message: String?, dismissCompletion: (() -> Void)?) -> UIViewController?
}

///
public class AcquiringUISDK: NSObject {
    private weak var presentingViewController: UIViewController?
    //
    private var acquiringSdk: AcquiringSdk
    private weak var acquiringView: AcquiringView?
    private weak var cardsListView: CardListDataSourceStatusListener?
    internal var acquiringViewConfiguration: AcquiringViewConfiguration?
    private var acquiringConfiguration: AcquiringConfiguration?
    private let uiSDKConfiguration: AcquiringUISDKConfiguration
    //
    private var startPaymentInitData: PaymentInitData?
    private var paymentInitPayload: InitPayload?
    private var onPaymentCompletionHandler: PaymentCompletionHandler?
    private var finishPaymentState: Result<GetPaymentStatePayload, Error>?

    // 3ds web view Checking
    private weak var webViewController: WebViewController?
    private var webView3DSCheckingTerminationUrl: String?
    private var on3DSCheckingCompletionHandler: PaymentCompletionHandler?
    private var on3DSCheckingAddCardCompletionHandler: AddCardCompletionHandler?
    // random amount
    private var onRandomAmountCheckingAddCardCompletionHandler: AddCardCompletionHandler?
    //
    private var webViewFor3DSChecking: WKWebView?

    // data providers
    private var cardListDataProvider: CardListDataProvider?
    private var checkPaymentStatus: PaymentStatusServiceProvider?
    
    private let assembly: UIAssembly

    public init(acquiringSdkConfiguration: AcquiringSdkConfiguration,
                uiSDKConfiguration: AcquiringUISDKConfiguration) throws {
        acquiringSdk = try AcquiringSdk(configuration: acquiringSdkConfiguration)
        assembly = UIAssembly(uiSDKConfiguration: uiSDKConfiguration)
        self.uiSDKConfiguration = uiSDKConfiguration
        AcqLoc.instance.setup(lang: nil, table: nil, bundle: nil)
    }

    /// Вызывается кода пользователь привязывается карту.
    /// Нужно указать с каким методом привязывать карту, по умолчанию `PaymentCardCheckType.no` - на усмотрение сервера
    public var addCardNeedSetCheckTypeHandler: (() -> PaymentCardCheckType)?
    
    public func paymentController(uiProvider: PaymentControllerUIProvider,
                                  delegate: PaymentControllerDelegate,
                                  dataSource: PaymentControllerDataSource? = nil) -> PaymentController {
        let paymentController = assembly.paymentController(acquiringSDK: acquiringSdk,
                                                           acquiringUISDK: self)
        paymentController.uiProvider = uiProvider
        paymentController.delegate = delegate
        paymentController.dataSource = dataSource
        
        return paymentController
    }

    public func setupCardListDataProvider(for customer: String, statusListener: CardListDataSourceStatusListener? = nil) {
        let provider: CardListDataProvider
        if let cardListDataProvider = self.cardListDataProvider {
            provider = cardListDataProvider.customerKey == customer
                ? cardListDataProvider
                : CardListDataProvider(sdk: acquiringSdk, customerKey: customer)
        } else {
            provider = CardListDataProvider(sdk: acquiringSdk, customerKey: customer)
        }
        
        self.cardListDataProvider = provider

        if statusListener == nil {
            cardListDataProvider?.dataSourceStatusListener = self
        } else {
            cardListDataProvider?.dataSourceStatusListener = statusListener
        }
    }

    public func presentAddCardView(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfiguration, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
        AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

        self.presentingViewController = presentingViewController
        acquiringViewConfiguration = configuration

        setupCardListDataProvider(for: customerKey)

        // create
        let modalViewController = AddNewCardViewController(nibName: "PopUpViewContoller", bundle: .uiResources)
        // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
        // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
        // будет краш из-за того, что там необходим force unwrap
        // TODO: Отрефачить эту историю!
        modalViewController.cardListDataSourceDelegate = self
        modalViewController.scanerDataSource = configuration.scaner
        modalViewController.alertViewHelper = configuration.alertViewHelper

        modalViewController.completeHandler = { result in
            completeHandler(result)
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: presentingViewController)
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(modalViewController, animated: true, completion: {
            _ = presentationController
        })
    }

    ///
    /// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
    public func presentPaymentView(on presentingViewController: UIViewController,
                                   paymentData: PaymentInitData,
                                   configuration: AcquiringViewConfiguration,
                                   acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        onPaymentCompletionHandler = completionHandler
        acquiringViewConfiguration = configuration
        self.acquiringConfiguration = acquiringConfiguration

        presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { [weak self] view in
            switch acquiringConfiguration.paymentStage {
            case .none:
                self?.startPay(paymentData)
            case let .paymentId(paymentId):
                self?.paymentInitPayload = InitPayload(amount: paymentData.amount,
                                                       orderId: paymentData.orderId,
                                                       paymentId: String(paymentId),
                                                       status: .unknown)
                view.changedStatus(.ready)
            }
        }

        acquiringView?.onTouchButtonPay = { [weak self] in
            if let cardRequisites = self?.acquiringView?.cardRequisites(),
               let paymentId = self?.paymentInitPayload?.paymentId {
                self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: self?.acquiringView?.infoEmail())
            }
        }

        acquiringView?.onTouchButtonSBP = { [weak self] in
            if let paymentId = self?.paymentInitPayload?.paymentId {
                self?.presentSbpActivity(paymentId: paymentId, paymentInvoiceSource: .url, configuration: configuration)
            }
        }
    }

    ///
    /// Оплатить на основе родительского платежа, регулярный платеж
    public func presentPaymentView(on presentingViewController: UIViewController,
                                   paymentData: PaymentInitData,
                                   parentPaymentId: PaymentId,
                                   configuration: AcquiringViewConfiguration,
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        self.presentingViewController = presentingViewController
        acquiringViewConfiguration = configuration
        onPaymentCompletionHandler = completionHandler

        startChargeWith(paymentData, parentPaymentId: parentPaymentId, presentingViewController: presentingViewController, configuration: configuration)
    }

    ///
    ///
    public func presentAlertView(on presentingViewController: UIViewController, title: String, icon: AcquiringAlertIconType = .success, autoCloseTime: TimeInterval = 3) {
        let alert = AcquiringAlertViewController.create()
        alert.present(on: presentingViewController, title: title, icon: icon, autoCloseTime: autoCloseTime)
    }

    // MARK: Система Быстрых Платежей

    /// Проверить есть ли возможность оплаты с помощью СБП
    public func canMakePaymentsSBP() -> Bool {
        return uiSDKConfiguration.fpsEnabled
    }

    public func presentPaymentSbpQrImage(on presentingViewController: UIViewController,
                                         paymentData: PaymentInitData,
                                         configuration: AcquiringViewConfiguration,
                                         acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                         completionHandler: @escaping PaymentCompletionHandler)
    {
        presentPaymentSbp(on: presentingViewController,
                          paymentInvoiceSource: .imageSVG,
                          paymentData: paymentData,
                          configuration: configuration,
                          acquiringConfiguration: acquiringConfiguration) { response in
            completionHandler(response)
        }
    }

    public func presentPaymentSbpUrl(on presentingViewController: UIViewController,
                                     paymentData: PaymentInitData,
                                     configuration: AcquiringViewConfiguration,
                                     acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                     completionHandler: @escaping PaymentCompletionHandler)
    {
        presentPaymentSbp(on: presentingViewController,
                          paymentInvoiceSource: .url,
                          paymentData: paymentData,
                          configuration: configuration,
                          acquiringConfiguration: acquiringConfiguration) { response in
            completionHandler(response)
        }
    }

    private func presentPaymentSbp(on presentingViewController: UIViewController,
                                   paymentInvoiceSource: PaymentInvoiceSBPSourceType,
                                   paymentData: PaymentInitData,
                                   configuration: AcquiringViewConfiguration,
                                   acquiringConfiguration: AcquiringConfiguration,
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        onPaymentCompletionHandler = completionHandler
        self.acquiringConfiguration = acquiringConfiguration

        let presentSbpActivity: (PaymentId) -> Void = { [weak self] paymentId in
            self?.paymentInitPayload = InitPayload(amount: paymentData.amount,
                                                   orderId: paymentData.orderId,
                                                   paymentId: paymentId,
                                                   status: .unknown)
            self?.presentSbpActivity(paymentId: paymentId, paymentInvoiceSource: paymentInvoiceSource, configuration: configuration)
        }

        presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { [weak self] _ in
            switch acquiringConfiguration.paymentStage {
            case .none:
                self?.initPay(paymentData: paymentData) { [weak self] response in
                    switch response {
                    case let .success(initResponse):
                        presentSbpActivity(initResponse.paymentId)
                    case let .failure(error):
                        self?.paymentInitPayload = nil
                        DispatchQueue.main.async {
                            self?.acquiringView?.closeVC(animated: true) {
                                completionHandler(.failure(error))
                            }
                        }
                    }
                }
            case let .paymentId(paymentId):
                presentSbpActivity(paymentId)
            }
        }
    }

    public func presentPaymentQRCollector(on presentingViewController: UIViewController, configuration: AcquiringViewConfiguration) {
        onPaymentCompletionHandler = nil

        if configuration.startViewHeight == nil {
            configuration.startViewHeight = presentingViewController.view.frame.size.width + 80
        }

        presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: configuration) { view in
            let viewTitle = AcqLoc.instance.localize("TinkoffAcquiring.view.title.payQRCode")
            view.changedStatus(.initWaiting)
            self.getStaticQRCode { [weak view] response in
                switch response {
                case let .success(qrCodeSVG):
                    DispatchQueue.main.async {
                        view?.changedStatus(.qrCodeStatic(qrCode: qrCodeSVG.qrCodeData, title: viewTitle))
                    }

                case let .failure(error):
                    DispatchQueue.main.async {
                        let alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error")

                        if let alert = configuration.alertViewHelper?.presentAlertView(alertTitle, message: error.localizedDescription, dismissCompletion: nil) {
                            view?.closeVC(animated: true) {
                                presentingViewController.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            AcquiringAlertViewController.create().present(on: presentingViewController, title: alertTitle)
                        }
                    }
                } // switch response
            } // getStaticQRCode
        }
    }

    // MARK: ApplePay

    public struct ApplePayConfiguration {
        public var merchantIdentifier: String = "merchant.tcsbank.ApplePayTestMerchantId"
        public var supportedNetworks: [PKPaymentNetwork] {
            if #available(iOS 14.5, *) {
                return [.masterCard, .visa, .mir]
            } else {
                return [.masterCard, .visa]
            }
        }
        
        public var capabilties = PKMerchantCapability(arrayLiteral: .capability3DS, .capabilityCredit, .capabilityDebit)

        public var countryCode: String = "RU"
        public var currencyCode: String = "RUB"
        public var shippingContact: PKContact?
        public var billingContact: PKContact?

        public init() {}
    }

    public func canMakePaymentsApplePay(with configuration: ApplePayConfiguration) -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: configuration.supportedNetworks, capabilities: configuration.capabilties)
    }

    /// 'Creating Payment Requests' https://developer.apple.com/library/archive/ApplePay_Guide/CreateRequest.html#//apple_ref/doc/uid/TP40014764-CH3-SW2
    public func presentPaymentApplePay(on presentingViewController: UIViewController,
                                       paymentData data: PaymentInitData,
                                       viewConfiguration: AcquiringViewConfiguration,
                                       acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                       paymentConfiguration: AcquiringUISDK.ApplePayConfiguration, completionHandler: @escaping PaymentCompletionHandler)
    {
        let request = PKPaymentRequest()
        request.merchantIdentifier = paymentConfiguration.merchantIdentifier
        request.supportedNetworks = paymentConfiguration.supportedNetworks
        request.merchantCapabilities = paymentConfiguration.capabilties
        request.countryCode = paymentConfiguration.countryCode
        request.currencyCode = paymentConfiguration.currencyCode
        request.shippingContact = paymentConfiguration.shippingContact
        request.billingContact = paymentConfiguration.billingContact

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: data.description ?? "", amount: NSDecimalNumber(value: Double(data.amount) / Double(100.0))),
        ]

        self.presentingViewController = presentingViewController
        onPaymentCompletionHandler = completionHandler
        self.acquiringConfiguration = acquiringConfiguration
        viewConfiguration.startViewHeight = 120

        let presentApplePayActivity: (PaymentId) -> Void = { [weak self] paymentId in
            self?.paymentInitPayload = InitPayload(amount: data.amount,
                                                   orderId: data.orderId,
                                                   paymentId: paymentId,
                                                   status: .unknown)
            self?.presentApplePayActivity(request)
        }

        presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: viewConfiguration) { _ in
            switch acquiringConfiguration.paymentStage {
            case .none:
                self.initPay(paymentData: data) { [weak self] response in
                    switch response {
                    case let .success(initPayload):
                        self?.paymentInitPayload = initPayload
                        DispatchQueue.main.async {
                            presentApplePayActivity(initPayload.paymentId)
                        }

                    case let .failure(error):
                        self?.paymentInitPayload = nil
                        DispatchQueue.main.async {
                            self?.acquiringView?.closeVC(animated: true) {
                                completionHandler(.failure(error))
                            }
                        }
                    }
                }
            case let .paymentId(paymentId):
                presentApplePayActivity(paymentId)
            }
        }
    }

    private func presentApplePayActivity(_ request: PKPaymentRequest) {
        guard let viewController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            acquiringView?.closeVC(animated: true) {
                let error = NSError(domain: AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"),
                                    code: 0,
                                    userInfo: nil)

                self.onPaymentCompletionHandler?(.failure(error))
            }

            return
        }

        viewController.delegate = self

        acquiringView?.presentVC(viewController, animated: true) { // [weak self] in
            // self?.acquiringView.setViewHeight(viewController.view.frame.height)
        }
    }

    private func getStaticQRCode(completionHandler: @escaping (_ result: Result<GetStaticQrPayload, Error>) -> Void) {
        _ = acquiringSdk.paymentInvoiceQRCodeCollector(data: PaymentInvoiceSBPSourceType.imageSVG, completionHandler: { response in
            completionHandler(response)
        })
    }

    private func presentSbpActivity(paymentId: PaymentId, paymentInvoiceSource: PaymentInvoiceSBPSourceType, configuration: AcquiringViewConfiguration) {
        let paymentInvoice = PaymentInvoiceQRCodeData(paymentId: paymentId, paymentInvoiceType: paymentInvoiceSource)
        _ = acquiringSdk.paymentInvoiceQRCode(data: paymentInvoice) { [weak self] response in
            switch response {
            case let .success(qrCodeResponse):
                DispatchQueue.main.async {
                    if paymentInvoiceSource == .url, let url = URL(string: qrCodeResponse.qrCodeData) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:]) { _ in
                                self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                                self?.acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: "Выбор источника оплаты"))
                            }
                        } else {
                            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
                            activityViewController.excludedActivityTypes = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks, .markupAsPDF]

                            activityViewController.completionWithItemsHandler = { (_: UIActivity.ActivityType?, _: Bool, _: [Any]?, _: Error?) in
                                self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                            }

                            self?.acquiringView?.presentVC(activityViewController, animated: true, completion: {
                                self?.acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: "Выбор источника оплаты"))
                            })
                        }
                    } else {
                        self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                    }
                }

            case let .failure(error):
                self?.paymentInitPayload = nil
                DispatchQueue.main.async {
                    self?.acquiringView?.changedStatus(.error(error))

                    let alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error")
                    if let alert = configuration.alertViewHelper?.presentAlertView(alertTitle, message: error.localizedDescription, dismissCompletion: nil) {
                        self?.presentingViewController?.present(alert, animated: true, completion: {
                            //
                        })
                    } else {
                        if let presentingView = self?.presentingViewController {
                            AcquiringAlertViewController.create().present(on: presentingView, title: alertTitle)
                        }
                    }
                }
            }
        }
    }

    private func sbpWaitingIncominPayment(paymentId: PaymentId, source: String, sourceType: PaymentInvoiceSBPSourceType) {
        let completionStatus: [PaymentStatus] = [.confirmed, .checked3ds, .refunded, .reversed, .rejected]
        let completionHandler = onPaymentCompletionHandler

        checkPaymentStatus = PaymentStatusServiceProvider(sdk: acquiringSdk, paymentId: paymentId)
        checkPaymentStatus?.onStatusUpdated = { [weak self] fetchStatus in
            switch fetchStatus {
            case let .object(response):
                if completionStatus.contains(response.status) {
                    self?.acquiringView?.closeVC(animated: true, completion: {
                        completionHandler?(.success(response))
                    })
                }

            default:
                break
            }
        }

        if sourceType == .url {
            acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: source, status: "Ожидание оплаты"))
        } else {
            acquiringView?.changedStatus(.paymentWaitingSBPQrCode(qrCode: source, status: "Ожидание оплаты"))
        }

        checkPaymentStatus?.fetchStatus(completionStatus: completionStatus)
    }

    // MARK: Create and Setup AcquiringViewController
    
    internal func presentAcquiringPaymentView(presentingViewController: UIViewController,
                                              customerKey: String?,
                                              configuration: AcquiringViewConfiguration,
                                              onPresenting: @escaping ((AcquiringView) -> Void))
    {
        self.presentingViewController = presentingViewController
        AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

        // create
        let modalViewController = AcquiringPaymentViewController(nibName: "AcquiringPaymentViewController", bundle: .uiResources)

        var fields: [AcquiringViewTableViewCells] = []

        var estimatedViewHeight: CGFloat = 300

        if let startViewHeight = configuration.startViewHeight {
            estimatedViewHeight = startViewHeight
        }

        configuration.fields.forEach { field in
            switch field {
            case let .amount(title, amount):
                fields.append(.amount(title: title, amount: amount))
                estimatedViewHeight += 50
            case let .detail(title):
                fields.append(.productDetail(title: title))
                estimatedViewHeight += 50
            case .buttonPaySPB:
                fields.append(.buttonPaySBP)
                estimatedViewHeight += 120
            case let .email(value, placeholder):
                fields.append(.email(value: value, placeholder: placeholder))
                estimatedViewHeight += 64
            }
        }

        modalViewController.modalMinHeight = estimatedViewHeight
        modalViewController.setCells(fields)

        modalViewController.title = configuration.viewTitle
        modalViewController.scanerDataSource = configuration.scaner
        modalViewController.alertViewHelper = configuration.alertViewHelper

        acquiringView = modalViewController
        
        if let key = customerKey {
            setupCardListDataProvider(for: key)
            cardListDataProvider?.update()
            // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
            // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
            // будет краш из-за того, что там необходим force unwrap
            // TODO: Отрефачить эту историю!
            modalViewController.cardListDataSourceDelegate = self
        }

        modalViewController.onTouchButtonShowCardList = { [weak self, weak modalViewController] in
            guard let self = self else { return }
            
            let viewController = CardsViewController(nibName: "CardsViewController", bundle: .uiResources)
            viewController.scanerDataSource = modalViewController?.scanerDataSource
            viewController.alertViewHelper = modalViewController?.alertViewHelper
            self.cardsListView = viewController
            
            // проверяем, что cardListDataProvider не nil, поэтому мы можем
            // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
            // будет краш из-за того, что там необходим force unwrap
            // TODO: Отрефачить эту историю!
            if self.cardListDataProvider != nil {
                viewController.cardListDataSourceDelegate = self
            }
            
            let cardListNController = UINavigationController(rootViewController: viewController)
            if self.acquiringView != nil {
                self.acquiringView?.presentVC(cardListNController, animated: true, completion: nil)
            } else {
                self.presentingViewController?.present(cardListNController, animated: true, completion: nil)
            }
        }

        modalViewController.onCancelPayment = { [weak self] in
            self?.cancelPayment()
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: presentingViewController)
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(modalViewController, animated: true, completion: {
            _ = presentationController
            onPresenting(modalViewController)
        })
    }

    // MARK: Payment

    private func startPay(_ initPaymentData: PaymentInitData) {
        startPaymentInitData = initPaymentData
        initPay(paymentData: initPaymentData) { [weak self] response in
            switch response {
            case let .success(initPayload):
                self?.paymentInitPayload = initPayload
                DispatchQueue.main.async {
                    self?.acquiringView?.changedStatus(.ready)
                }

            case let .failure(error):
                self?.paymentInitPayload = nil
                DispatchQueue.main.async {
                    self?.acquiringView?.closeVC(animated: true) {
                        self?.onPaymentCompletionHandler?(.failure(error))
                    }
                }
            }
        } // initPay
    }

    private func initPay(paymentData: PaymentInitData, completionHandler: @escaping (_ result: Result<InitPayload, Error>) -> Void) {
        acquiringView?.changedStatus(.initWaiting)
        acquiringView?.setPaymentType(paymentData.savingAsParentPayment == true ? .recurrent : .standart)
        _ = acquiringSdk.paymentInit(data: paymentData) { response in
            completionHandler(response)
        }
    }

    /// Для сценария когда при прохождении 3ds v2 произошла ошибка.
    /// Инициируем новый платеж и и завершаем его без проверки версии 3ds, те если потребуется прохождение топрохолим по версии 1.0
    private func paymentTryAgainWith3dsV1(_ data: PaymentInitData, completionHandler: @escaping PaymentCompletionHandler) {
        paymentInitPayload = nil

        let repeatFinish: (PaymentId) -> Void = { [weak self] paymentId in
            if let cardRequisites = self?.acquiringView?.cardRequisites() {
                var requestData = PaymentFinishRequestData(paymentId: String(paymentId), paymentSource: cardRequisites)
                requestData.setInfoEmail(self?.acquiringView?.infoEmail())

                self?.finishAuthorize(requestData: requestData, treeDSmessageVersion: "1.0", completionHandler: { finishResponse in
                    completionHandler(finishResponse)
                })
            }
        }

        let paymentStage = acquiringConfiguration?.paymentStage ?? .none
        switch paymentStage {
        case .none:
            initPay(paymentData: data) { initResponse in
                switch initResponse {
                case let .success(successResponse):
                    // завершаем оплату
                    DispatchQueue.main.async {
                        repeatFinish(successResponse.paymentId)
                    }

                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } // initPay
        case let .paymentId(paymentId):
            repeatFinish(paymentId)
        }
    }

    // MARK: Pay by cardId and card requisites

    public func pay(on presentingViewController: UIViewController,
                    initPaymentData: PaymentInitData,
                    cardRequisites: PaymentSourceData,
                    infoEmail: String?,
                    configuration: AcquiringViewConfiguration,
                    acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                    completionHandler: @escaping PaymentCompletionHandler)
    {
        self.presentingViewController = presentingViewController
        startPaymentInitData = initPaymentData
        acquiringViewConfiguration = configuration
        onPaymentCompletionHandler = completionHandler
        self.acquiringConfiguration = acquiringConfiguration

        let finishPay: (PaymentId) -> Void = { [weak self] paymentId in
            self?.paymentInitPayload = InitPayload(amount: initPaymentData.amount,
                                                   orderId: initPaymentData.orderId,
                                                   paymentId: paymentId,
                                                   status: .unknown)
            self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: infoEmail)
            self?.acquiringView?.changedStatus(.ready)
        }

        switch acquiringConfiguration.paymentStage {
        case .none:
            initPay(paymentData: initPaymentData) { [weak self] response in
                switch response {
                case let .success(initPayload):
                    DispatchQueue.main.async {
                        finishPay(initPayload.paymentId)
                    }
                case let .failure(error):
                    self?.paymentInitPayload = nil
                    DispatchQueue.main.async {
                        self?.acquiringView?.closeVC(animated: true) {
                            self?.onPaymentCompletionHandler?(.failure(error))
                        }
                    }
                }
            }
        case let .paymentId(paymentId):
            finishPay(paymentId)
        }
    }

    // MARK: Charge

    private func startChargeWith(_ paymentData: PaymentInitData, parentPaymentId: PaymentId, presentingViewController: UIViewController, configuration: AcquiringViewConfiguration) {
        var data = paymentData
        data.addPaymentData(["chargeFlag": "true"])

        _ = acquiringSdk.paymentInit(data: data) { initResponse in
            switch initResponse {
            case let .success(initPayload):
                self.paymentInitPayload = initPayload
                DispatchQueue.main.async {
                    let chargeData = PaymentChargeRequestData(paymentId: initPayload.paymentId, parentPaymentId: parentPaymentId)
                    _ = self.acquiringSdk.chargePayment(data: chargeData, completionHandler: { chargeResponse in
                        switch chargeResponse {
                        case let .success(chargePayload):
                            DispatchQueue.main.async { [weak self] in
                                if self?.acquiringView != nil {
                                    self?.acquiringView?.closeVC(animated: true, completion: {
                                        self?.onPaymentCompletionHandler?(.success(chargePayload.paymentState))
                                    })
                                } else {
                                    self?.onPaymentCompletionHandler?(.success(chargePayload.paymentState))
                                }
                            }

                        case let .failure(error):
                            if (error as NSError).code == 104 {
                                data.addPaymentData(["failMapiSessionId": "\(initPayload.paymentId)"])
                                data.addPaymentData(["recurringType": "12"])
                                data.savingAsParentPayment = true
                                DispatchQueue.main.async {
                                    var chargePaymentId = initPayload.paymentId
                                    self.presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { _ in
                                        self.acquiringView?.changedStatus(.initWaiting)
                                        self.initPay(paymentData: data, completionHandler: { initResponse in
                                            switch initResponse {
                                            case let .success(successInitPayload):
                                                self.paymentInitPayload = successInitPayload
                                                DispatchQueue.main.async { [weak self] in
                                                    chargePaymentId = successInitPayload.paymentId
                                                    self?.acquiringView?.changedStatus(.paymentWainingCVC(cardParentId: parentPaymentId))
                                                }

                                            case let .failure(error):
                                                DispatchQueue.main.async { [weak self] in
                                                    self?.acquiringView?.closeVC(animated: true) {
                                                        self?.onPaymentCompletionHandler?(.failure(error))
                                                    }
                                                }
                                            }
                                        })

                                        self.acquiringView?.onTouchButtonPay = { [weak self] in
                                            if let cardRequisites = self?.acquiringView?.cardRequisites() {
                                                self?.finishPay(cardRequisites: cardRequisites, paymentId: chargePaymentId, infoEmail: self?.acquiringView?.infoEmail())
                                            }
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async { [weak self] in
                                    if self?.acquiringView != nil {
                                        self?.acquiringView?.closeVC(animated: true, completion: {
                                            self?.onPaymentCompletionHandler?(.failure(error))
                                        })
                                    } else {
                                        self?.onPaymentCompletionHandler?(.failure(error))
                                    }
                                }
                            }
                        } // chargeResponse
                    }) // charge finish
                }

            case let .failure(error):
                self.paymentInitPayload = nil
                DispatchQueue.main.async { [weak self] in
                    if self?.acquiringView != nil {
                        self?.acquiringView?.closeVC(animated: true, completion: {
                            self?.onPaymentCompletionHandler?(.failure(error))
                        })
                    } else {
                        self?.onPaymentCompletionHandler?(.failure(error))
                    }
                }
            } // switch initResponse
        } // acquiringSdk.paymentInit
    } // startChargeWith

    // MARK: FinishPay & Finish Authorize

    private func finishPay(cardRequisites: PaymentSourceData, paymentId: PaymentId, infoEmail: String?) {
        var requestData = PaymentFinishRequestData(paymentId: String(paymentId), paymentSource: cardRequisites)
        requestData.setInfoEmail(infoEmail)
        acquiringView?.changedStatus(.paymentWaiting(status: nil))

        let completion = onPaymentCompletionHandler
        check3dsVersionAndFinishAuthorize(requestData: requestData) { [weak self] response in
            switch response {
            case let .success(paymentResponse):
                DispatchQueue.main.async { [weak self] in
                    if let view = self?.acquiringView {
                        view.closeVC(animated: true) {
                            completion?(.success(paymentResponse))
                        }
                    } else {
                        completion?(.success(paymentResponse))
                    }
                }

            case let .failure(error):
                DispatchQueue.main.async { [weak self] in
                    if let view = self?.acquiringView {
                        view.closeVC(animated: true) {
                            completion?(.failure(error))
                        }
                    } else {
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    private func finishAuthorize(requestData: PaymentFinishRequestData, treeDSmessageVersion: String, completionHandler: @escaping PaymentCompletionHandler) {
        _ = acquiringSdk.paymentFinish(data: requestData, completionHandler: { response in
            switch response {
            case let .success(finishResult):
                switch finishResult.responseStatus {
                case let .needConfirmation3DS(confirmation3DSData):
                    DispatchQueue.main.async {
                        self.on3DSCheckingCompletionHandler = { response in
                            completionHandler(response)
                        }

                        self.present3DSChecking(with: confirmation3DSData, presenter: self.acquiringView) { [weak self] in
                            self?.cancelPayment()
                        }
                    }

                case let .needConfirmation3DSACS(confirmation3DSDataACS):
                    DispatchQueue.main.async {
                        self.on3DSCheckingCompletionHandler = { response in
                            completionHandler(response)
                        }

                        self.present3DSCheckingACS(with: confirmation3DSDataACS, messageVersion: treeDSmessageVersion, presenter: self.acquiringView) { [weak self] in
                            self?.cancelPayment()
                        }
                    }

                case .success:
                    completionHandler(.success(finishResult.paymentState))
                } // case .success

            case let .failure(error):
                if (error as NSError).code == 106 {
                    if let paymentInitData = self.startPaymentInitData {
                        DispatchQueue.main.async {
                            self.paymentTryAgainWith3dsV1(paymentInitData) { response in
                                completionHandler(response)
                            }
                        }
                    }
                } else {
                    completionHandler(.failure(error))
                }
            } // switch response
        }) // paymentFinish
    }

    private func check3dsVersionAndFinishAuthorize(requestData: PaymentFinishRequestData, completionHandler: @escaping PaymentCompletionHandler) {
        let check3DSRequestData = Check3DSRequestData(paymentId: requestData.paymentId,
                                                      paymentSource: requestData.paymentSource)
        _ = acquiringSdk.check3dsVersion(data: check3DSRequestData, completionHandler: { checkResponse in
            switch checkResponse {
            case let .success(checkResult):
                var finistRequestData = requestData
                // сбор информации для прохождения 3DS v2
                if let tdsServerTransID = checkResult.tdsServerTransID, let threeDSMethodURL = checkResult.threeDSMethodURL {
                    // вызываем web view для проверки девайса
                    self.threeDSMethodCheckURL(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL, presenter: self.acquiringView)
                    // собираем информацию о девайсе
                    let screenSize = UIScreen.main.bounds.size
                    let deviceInfo = DeviceInfoParams(cresCallbackUrl: (try? self.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString) ?? "",
                                                      languageId: self.acquiringSdk.languageKey.rawValue,
                                                      screenWidth: Int(screenSize.width),
                                                      screenHeight: Int(screenSize.height))
                    finistRequestData.setDeviceInfo(info: deviceInfo)
                    finistRequestData.setThreeDSVersion(checkResult.version)
                    finistRequestData.setIpAddress(self.acquiringSdk.networkIpAddress()?.fullStringValue)
                }
                // завершаем оплату
                self.finishAuthorize(requestData: finistRequestData, treeDSmessageVersion: checkResult.version) { finishResponse in
                    completionHandler(finishResponse)
                }

            case let .failure(error):
                completionHandler(.failure(error))
            }
        })
    }

    private func threeDSMethodCheckURL(tdsServerTransID: String, threeDSMethodURL: String, presenter: AcquiringView?) {
        let urlData = Checking3DSURLData(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL)
        guard let request = try? acquiringSdk.createChecking3DSURL(data: urlData) else {
            return
        }

        DispatchQueue.main.async {
            if presenter != nil {
                presenter?.checkDeviceFor3DSData(with: request)
            } else {
                self.webViewFor3DSChecking = WKWebView()
                self.webViewFor3DSChecking?.load(request)
            }
        }
    }

    private func cancelPayment() {
        if let paymentInitPayload = paymentInitPayload {
            let getStatePayload = GetPaymentStatePayload(paymentId: paymentInitPayload.paymentId,
                                                         amount: paymentInitPayload.amount,
                                                         orderId: paymentInitPayload.orderId,
                                                         status: .cancelled)
            onPaymentCompletionHandler?(.success(getStatePayload))
        }
    }

    private func cancelAddCard() {
        onRandomAmountCheckingAddCardCompletionHandler?(.success(AddCardStatusResponse(success: false, errorCode: 0)))
    }

    fileprivate func presentWebView(on _: AcquiringView?, load request: URLRequest, onCancel: @escaping (() -> Void)) {
        let viewController = WebViewController(nibName: "WebViewController", bundle: .uiResources)
        webViewController = viewController
        viewController.onCancel = { [weak self] in
            if self?.acquiringView != nil {
                self?.acquiringView?.closeVC(animated: true) {
                    onCancel()
                }
            } else {
                onCancel()
            }
        }

        let onPresenting = {
            viewController.webView.navigationDelegate = self
            viewController.webView.load(request)
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        presentingViewController?.presentOnTop(viewController: navigationController,
                                               animated: true,
                                               completion: {
                                                onPresenting()
                                               })
    }

    private func present3DSChecking(with data: Confirmation3DSData, presenter: AcquiringView?, onCancel: @escaping (() -> Void)) {
        guard let request = try? acquiringSdk.createConfirmation3DSRequest(data: data) else {
            return
        }

        presentWebView(on: presenter, load: request, onCancel: onCancel)
    }

    private func present3DSCheckingACS(with data: Confirmation3DSDataACS, messageVersion: String, presenter: AcquiringView?, onCancel: @escaping (() -> Void)) {
        guard let request = try? acquiringSdk.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion) else {
            return
        }

        presentWebView(on: presenter, load: request, onCancel: onCancel)
    }

    private func presentRandomAmounChecking(with requestKey: String, presenter _: AcquiringView?, alertViewHelper: AcquiringAlertViewProtocol?, onCancel: @escaping (() -> Void)) {
        let viewController = RandomAmounCheckingViewController(nibName: "RandomAmounCheckingViewController", bundle: .uiResources)

        viewController.onCancel = {
            onCancel()
        }

        viewController.completeHandler = { [weak self, weak viewController] value in
            viewController?.viewWaiting.isHidden = false
            self?.checkStateSubmitRandomAmount(amount: value, requestKey: requestKey) { response in
                DispatchQueue.main.async {
                    viewController?.viewWaiting.isHidden = true
                    switch response {
                    case let .success(payload):
                        viewController?.onCancel = nil
                        viewController?.dismiss(animated: true, completion: {
                            let addCardStatusResponse = AddCardStatusResponse(success: true,
                                                                              errorCode: 0,
                                                                              requestKey: payload.requestKey,
                                                                              cardId: payload.cardId)
                            self?.onRandomAmountCheckingAddCardCompletionHandler?(.success(addCardStatusResponse))
                        })
                    case let .failure(error):
                        viewController?.dismiss(animated: true, completion: {
                            let alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error")
                            if let alert = alertViewHelper?.presentAlertView(alertTitle, message: error.localizedDescription, dismissCompletion: nil) {
                                self?.presentingViewController?.presentOnTop(viewController: alert, animated: true)
                            } else {
                                if let topViewControllerInStack = self?.presentingViewController?.topPresentedViewControllerOrSelfIfNotPresenting {
                                    AcquiringAlertViewController.create().present(on: topViewControllerInStack, title: alertTitle)
                                }
                            }
                        })
                    }
                }
            }
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        presentingViewController?.presentOnTop(viewController: navigationController,
                                               animated: true)
    }
}

extension AcquiringUISDK: CardListDataSourceStatusListener {
    // MARK: CardListDataSourceStatusListener

    public func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>) {
        cardsListView?.cardsListUpdated(status)
        acquiringView?.cardsListUpdated(status)
    }
}

extension AcquiringUISDK: AcquiringCardListDataSourceDelegate {
    func getCardListNumberOfCards() -> Int {
        return cardListDataProvider!.count()
    }
    
    func getCardListFetchStatus() -> FetchStatus<[PaymentCard]> {
        return cardListDataProvider!.fetchStatus
    }
    
    func getCardListCard(at index: Int) -> PaymentCard {
        return cardListDataProvider!.item(at: index)
    }
    
    func getCardListCard(cardId: String) -> PaymentCard? {
        return cardListDataProvider!.item(with: cardId)
    }
    
    func getCardListCard(parentPaymentId: PaymentId) -> PaymentCard? {
        return cardListDataProvider!.item(with: parentPaymentId)
    }
    
    func getAllCards() -> [PaymentCard] {
        return cardListDataProvider!.allItems()
    }
    
    func cardListReload() {
        cardListDataProvider!.update()
    }
    
    func cardListToDeactivateCard(at index: Int,
                                  startHandler: (() -> Void)?,
                                  completion: ((PaymentCard?) -> Void)?) {
        let card = cardListDataProvider!.item(at: index)
        cardListDataProvider!.deactivateCard(cardId: card.cardId, startHandler: {
            startHandler?()
        }) { card in
            completion?(card)
        }
    }
    
    func cardListToAddCard(number: String,
                           expDate: String,
                           cvc: String,
                           addCardViewPresenter: AcquiringView,
                           alertViewHelper: AcquiringAlertViewProtocol?,
                           completeHandler: @escaping (Result<PaymentCard?, Error>) -> Void) {
        let checkType: String
        if let value = addCardNeedSetCheckTypeHandler?() {
            checkType = value.rawValue
        } else {
            checkType = PaymentCardCheckType.no.rawValue
        }
        
        cardListDataProvider!.addCard(number: number,
                                      expDate: expDate,
                                      cvc: cvc,
                                      checkType: checkType,
                                      confirmationHandler: { confirmationResponse, confirmationComplete in
                                        DispatchQueue.main.async { [weak self] in
                                            self?.checkConfirmAddCard(confirmationResponse, presenter: addCardViewPresenter, alertViewHelper: alertViewHelper, confirmationComplete)
                                        }
                                      },
                                      completeHandler: { response in
                                        DispatchQueue.main.async {
                                            completeHandler(response)
                                        }
                                      })
    }
    
    func presentAddCard(on presentingViewController: UIViewController,
                        customerKey: String,
                        configuration: AcquiringViewConfiguration,
                        completeHandler: @escaping (Result<PaymentCard?, Error>) -> Void) {
        AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

        self.presentingViewController = presentingViewController
        acquiringViewConfiguration = configuration

        setupCardListDataProvider(for: customerKey)

        // create
        let modalViewController = AddNewCardViewController(nibName: "PopUpViewContoller", bundle: .uiResources)
        
        // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
        // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
        // будет краш из-за того, что там необходим force unwrap
        // TODO: Отрефачить эту историю!
        modalViewController.cardListDataSourceDelegate = self
        modalViewController.scanerDataSource = configuration.scaner
        modalViewController.alertViewHelper = configuration.alertViewHelper

        modalViewController.completeHandler = { result in
            completeHandler(result)
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: presentingViewController)
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(modalViewController, animated: true, completion: {
            _ = presentationController
        })
    }
    
    // MARK: AcquiringPaymentCardLidtDataSourceDelegate
    
    public enum SDKError: Error {
        case noCustomerKey
    }
    
    private func getCardListDataProvider() throws -> CardListDataProvider {
        guard let cardListDataProvider = self.cardListDataProvider else {
            throw SDKError.noCustomerKey
        }
        return cardListDataProvider
    }

    public func customerKey() throws -> String {
        return try getCardListDataProvider().customerKey
    }

    public func cardListNumberOfCards() throws -> Int {
        return try getCardListDataProvider().count()
    }

    public func cardListFetchStatus() throws -> FetchStatus<[PaymentCard]> {
        return try getCardListDataProvider().fetchStatus
    }

    public func cardListCard(at index: Int) throws -> PaymentCard {
        return try getCardListDataProvider().item(at: index)
    }

    public func cardListCard(cardId: String) throws -> PaymentCard? {
        return try getCardListDataProvider().item(with: cardId)
    }

    public func cardListCard(parentPaymentId: PaymentId) throws -> PaymentCard? {
        return try getCardListDataProvider().item(with: parentPaymentId)
    }
    
    public func allCards() throws -> [PaymentCard] {
        return try getCardListDataProvider().allItems()
    }

    public func cardListReloadData() throws {
        return try getCardListDataProvider().update()
    }

    public func cardListDeactivateCard(at index: Int, startHandler: (() -> Void)?, completion: ((Result<PaymentCard?, Error>) -> Void)?) {
        do {
            let cardListProvider = try getCardListDataProvider()
            let card = cardListProvider.item(at: index)
            cardListProvider.deactivateCard(cardId: card.cardId, startHandler: {
                startHandler?()
            }) { card in
                completion?(.success(card))
            }
        } catch {
            completion?(.failure(error))
        }
    }
    
    private func checkConfirmAddCard(_ confirmationResponse: AttachCardPayload, presenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, _ confirmationComplete: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
        switch confirmationResponse.attachCardStatus {
        case let .needConfirmation3DS(confirmation3DSData):
            on3DSCheckingAddCardCompletionHandler = { response in
                confirmationComplete(response)
            }
            
            present3DSChecking(with: confirmation3DSData, presenter: presenter) { [weak self] in
                self?.cancelAddCard()
            }
            
        case let .needConfirmation3DSACS(confirmation3DSDataACS):
            on3DSCheckingAddCardCompletionHandler = { response in
                confirmationComplete(response)
            }
            
            present3DSCheckingACS(with: confirmation3DSDataACS, messageVersion: "1.0", presenter: presenter) { [weak self] in
                self?.cancelAddCard()
            }
            
        case let .needConfirmationRandomAmount(requestKey):
            onRandomAmountCheckingAddCardCompletionHandler = { response in
                confirmationComplete(response)
            }
            
            presentRandomAmounChecking(with: requestKey, presenter: presenter, alertViewHelper: alertViewHelper) { [weak self] in
                self?.cancelAddCard()
            }
            
        case .done:
            confirmationComplete(.success(AddCardStatusResponse(success: true, errorCode: 0, cardId: confirmationResponse.cardId)))
        }
    }
    
    private func checkStateSubmitRandomAmount(amount: Double, requestKey: String, _ confirmationComplete: @escaping (Result<SubmitRandomAmountPayload, Error>) -> Void) {
        let amountDecimal = NSDecimalNumber(value: amount)
        let data = SubmitRandomAmountData(amount: Int64(amountDecimal.multiplying(byPowerOf10: 2).uint64Value),
                                          requestKey: requestKey)
        _ = acquiringSdk.checkRandomAmount(data: data) { response in
            confirmationComplete(response)
        }
    }

    func cardListAddCard(number: String, expDate: String, cvc: String, addCardViewPresenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
        
        do {
            let cardListDataProvider = try getCardListDataProvider()
            let checkType: String
            if let value = addCardNeedSetCheckTypeHandler?() {
                checkType = value.rawValue
            } else {
                checkType = PaymentCardCheckType.no.rawValue
            }

            cardListDataProvider.addCard(number: number,
                                         expDate: expDate,
                                         cvc: cvc,
                                         checkType: checkType,
                                         confirmationHandler: { confirmationResponse, confirmationComplete in
                                             DispatchQueue.main.async { [weak self] in
                                                 self?.checkConfirmAddCard(confirmationResponse, presenter: addCardViewPresenter, alertViewHelper: alertViewHelper, confirmationComplete)
                                             }
                                         },
                                         completeHandler: { response in
                                             DispatchQueue.main.async {
                                                 completeHandler(response)
                                             }
                                         })
        } catch {
            completeHandler(.failure(error))
        }
    }

    public func presentCardList(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfiguration) {
        AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

        if acquiringViewConfiguration == nil {
            acquiringViewConfiguration = configuration
        }

        if self.presentingViewController == nil {
            self.presentingViewController = presentingViewController
        }
        
        setupCardListDataProvider(for: customerKey)

        // create
        let modalViewController = CardsViewController(nibName: "CardsViewController", bundle: .uiResources)
        // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
        // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
        // будет краш из-за того, что там необходим force unwrap
        // TODO: Отрефачить эту историю!
        modalViewController.cardListDataSourceDelegate = self
        modalViewController.title = configuration.viewTitle

        modalViewController.scanerDataSource = configuration.scaner
        modalViewController.alertViewHelper = configuration.alertViewHelper

        
        cardsListView = modalViewController
        // present
        let presentationController = UINavigationController(rootViewController: modalViewController)
        presentingViewController.present(presentationController, animated: true) {
            _ = presentationController
            // вызов setupCardListDataProvider выше гарантирует, что cardListDataProvider будет не nil
            self.cardListDataProvider?.update()
        }
    }
}

extension AcquiringUISDK: PKPaymentAuthorizationViewControllerDelegate {
    // MARK: PKPaymentAuthorizationViewControllerDelegate

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            if let result = self.finishPaymentState {
                self.acquiringView?.closeVC(animated: true) {
                    self.onPaymentCompletionHandler?(result)
                }
            } else {
                self.acquiringView?.closeVC(animated: true) {
                    self.cancelPayment()
                }
            }
        }
    }

    public func paymentAuthorizationViewController(_: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    {
        if let paymentId = paymentInitPayload?.paymentId {
            let paymentDataSource = PaymentSourceData.paymentData(payment.token.paymentData.base64EncodedString())
            let data = PaymentFinishRequestData(paymentId: paymentId,
                                                paymentSource: paymentDataSource)

            finishAuthorize(requestData: data, treeDSmessageVersion: "1") { [weak self] finishResponse in
                switch finishResponse {
                case let .failure(error):
                    DispatchQueue.main.async {
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                    }

                case .success:
                    DispatchQueue.main.async {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    }
                }
                
                self?.finishPaymentState = finishResponse
            } // self.finishAuthorize
        }
    }
}

extension AcquiringUISDK: WKNavigationDelegate {
    // MARK: WKNavigationDelegate

    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        webView.evaluateJavaScript("document.baseURI") { [weak self] value, error in
            guard error == nil, let stringValue = value as? String else {
                return
            }

            guard stringValue.hasSuffix("cancel.do") == false else {
                self?.webViewController?.onCancel?()
                return
            }

            if stringValue.hasSuffix((try? self?.acquiringSdk.confirmation3DSTerminationURL().absoluteString) ?? "") ||
                stringValue.hasSuffix((try? self?.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString) ?? "")
            {
                webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerText") { value, error in
                    // debugPrint("document.getElementsByTagName('pre')[0].innerText = \(value ?? "" )")
                    guard let responseString = value as? String, let data = responseString.data(using: .utf8) else {
                        return
                    }

                    self?.webViewController?.onCancel = nil

                    // decode as a default `AcquiringResponse`
                    guard let acquiringResponse = try? JSONDecoder().decode(AcquiringResponse.self, from: data) else {
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            let error = NSError(domain: AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"), code: 0, userInfo: nil)
                            self?.on3DSCheckingCompletionHandler?(.failure(error))
                            self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                        })

                        return
                    }

                    // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
                    guard acquiringResponse.success else {
                        let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
                                            code: acquiringResponse.errorCode,
                                            userInfo: try? acquiringResponse.encode2JSONObject())

                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.on3DSCheckingCompletionHandler?(.failure(error))
                            self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                        })

                        return
                    }

                    // data in `PaymentStatusResponse` format
                    if self?.on3DSCheckingCompletionHandler != nil {
                        guard let responseObject: PaymentStatusResponse = try? JSONDecoder().decode(PaymentStatusResponse.self, from: data) else {
                            let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
                                                code: acquiringResponse.errorCode,
                                                userInfo: try? acquiringResponse.encode2JSONObject())

                            self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                                self?.on3DSCheckingCompletionHandler?(.failure(error))
                            })

                            return
                        }

                        //
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            #warning("Раскомментировать и актуализировать, когда responseObject будет парситься в GetStatePayload переведу на новый api слой")
//                            self?.on3DSCheckingCompletionHandler?(.success(responseObject))
                        })
                    }

                    // data in `AddCardStatusResponse` format
                    if self?.on3DSCheckingAddCardCompletionHandler != nil {
                        guard let responseObject: AddCardStatusResponse = try? JSONDecoder().decode(AddCardStatusResponse.self, from: data) else {
                            let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
                                                code: acquiringResponse.errorCode,
                                                userInfo: try? acquiringResponse.encode2JSONObject())

                            self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                                self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                            })

                            return
                        }

                        //
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.on3DSCheckingAddCardCompletionHandler?(.success(responseObject))
                        })
                    }
                } // getElementsByTagName('pre')
            } // termURL.hasSuffix confirmation3DSTerminationURL
        } // document.baseURI
    } // func webView didFinish
}
