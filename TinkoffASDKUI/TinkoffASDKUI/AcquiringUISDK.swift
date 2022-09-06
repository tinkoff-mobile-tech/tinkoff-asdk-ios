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
import ThreeDSWrapper

public protocol TinkoffPayDelegate: AnyObject {
    func tinkoffPayIsNotAllowed()
}

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
//        /// показывать кнопку оплаты Системы Быстрых Платежей
//        case buttonPaySPB
    }
    
    /// Стиль popup-экранов.
    public enum PopupStyle {
        /// Отображается только как bottom sheet.
        case bottomSheet
        /// Отображается как bottom sheet.
        /// При растягивании до верхней границы экран пушится в UINavigationController.
        case dynamic
    }

    public struct FeaturesOptions {
        public var fpsEnabled: Bool = false
        public var tinkoffPayEnabled: Bool = true

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
    public var popupStyle: PopupStyle = .dynamic
    public var tinkoffPayButtonStyle: TinkoffPayButton.DynamicStyle = .init(lightStyle: .black, darkStyle: .white)

    public init() {}
}

public struct AcquiringPaymentStageConfiguration {
    public enum PaymentStage {
        case `init`(paymentData: PaymentInitData)
        case finish(paymentId: Int64)
    }
    
    public let paymentStage: PaymentStage

    public init(paymentStage: PaymentStage) {
        self.paymentStage = paymentStage
    }
}

public struct AcquiringConfiguration {
    public enum PaymentStage {
        case none
        case paymentId(Int64)
    }

    public let paymentStage: PaymentStage

    public init(paymentStage: PaymentStage = .none) {
        self.paymentStage = paymentStage
    }
}

public typealias PaymentCompletionHandler = ((_ result: Result<PaymentStatusResponse, Error>) -> Void)
public typealias AddCardCompletionHandler = ((_ result: Result<AddCardStatusResponse, Error>) -> Void)

/// Сканер для реквизитов карты
public protocol AcquiringScanerProtocol: AnyObject {
    ///
    /// - Parameters:
    ///   - completion: результат сканирования, номер карты `number`, год `yy`, месяц `mm`
    /// - Returns: сканер UIViewController
    func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController?
}

/// Отображение не стандартного AlertView если в приложении используется не UIAlertController
public protocol AcquiringAlertViewProtocol: AnyObject {
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
    public var acquiringSdk: AcquiringSdk
    private let style: Style
    private weak var acquiringView: AcquiringView?
    private weak var cardsListView: CardListDataSourceStatusListener?
    private var acquiringViewConfiguration: AcquiringViewConfiguration?
    private var acquiringConfiguration: AcquiringConfiguration?
    //
    private var startPaymentInitData: PaymentInitData?
    private var paymentInitResponseData: PaymentInitResponseData?
    private var onPaymentCompletionHandler: PaymentCompletionHandler?
    private var finishPaymentStatusResponse: Result<PaymentStatusResponse, Error>?

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
    
    private let sbpAssembly: SBPAssembly
    private let tinkoffPayAssembly: TinkoffPayAssembly
    private let cardListAssembly: ICardListAssembly
    
    // App based threeDS
    private let tdsController: TDSController
    // ThreeDS feature flag
    private let shouldUseAppBasedThreeDSFlow = false

    private weak var logger: LoggerDelegate?
    
    
    public init(configuration: AcquiringSdkConfiguration,
                style: Style = DefaultStyle()) throws {
        acquiringSdk = try AcquiringSdk(configuration: configuration)
        self.style = style
        self.sbpAssembly = SBPAssembly(coreSDK: acquiringSdk, style: style)
        self.tinkoffPayAssembly = TinkoffPayAssembly(coreSDK: acquiringSdk,
                                                     tinkoffPayStatusCacheLifeTime: configuration.tinkoffPayStatusCacheLifeTime)
        let tdsWrapper = TDSWrapperBuilder(env: configuration.serverEnvironment, language: configuration.language).build()
        let tdsCertsManager = TDSCertsManager(acquiringSdk: acquiringSdk, tdsWrapper: tdsWrapper)
        let tdsTimeoutResolver = TDSTimeoutResolver()
        self.tdsController = TDSController(acquiringSdk: acquiringSdk,
                                           tdsWrapper: tdsWrapper,
                                           tdsCertsManager: tdsCertsManager,
                                           tdsTimeoutResolver: tdsTimeoutResolver)
        self.logger = configuration.logger
        self.cardListAssembly = CardListAssembly(primaryButtonStyle: style.bigButtonStyle)
    }

    /// Вызывается кода пользователь привязывает карту.
    /// Нужно указать с каким методом привязывать карту, по умолчанию `PaymentCardCheckType.no` - на усмотрение сервера
    public var addCardNeedSetCheckTypeHandler: (() -> PaymentCardCheckType)?
    
    public func setupCardListDataProvider(for customer: String, statusListener: CardListDataSourceStatusListener? = nil) {
        resolveCardListDataProvider(customerKey: customer, statusListener: statusListener)
    }

    @discardableResult
    private func resolveCardListDataProvider(
        customerKey: String,
        statusListener: CardListDataSourceStatusListener? = nil
    ) -> CardListDataProvider {
        let provider: CardListDataProvider
        if let cardListDataProvider = self.cardListDataProvider {
            provider = cardListDataProvider.customerKey == customerKey
                ? cardListDataProvider
                : CardListDataProvider(coreSDK: acquiringSdk, customerKey: customerKey)
        } else {
            provider = CardListDataProvider(coreSDK: acquiringSdk, customerKey: customerKey)
        }

        self.cardListDataProvider = provider

        if statusListener == nil {
            cardListDataProvider?.dataSourceStatusListener = self
        } else {
            cardListDataProvider?.dataSourceStatusListener = statusListener
        }

        return provider
    }

    public func presentAddCardView(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfiguration, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
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
        modalViewController.popupStyle = configuration.popupStyle
        modalViewController.style = .init(addCardButtonStyle: style.bigButtonStyle)

        modalViewController.completeHandler = { result in
            completeHandler(result)
        }
        
        modalViewController.cancelCompletion = {
            completeHandler(.success(nil))
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: presentingViewController)
        presentationController.cancelCompletion = {
            completeHandler(.success(nil))
        }
        
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(modalViewController, animated: true, completion: {
            _ = presentationController
        })
    }

    @available(*, deprecated, message: "Use presentPaymentView(on presentingViewController: UIViewController, acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration, configuration: AcquiringViewConfiguration,tinkoffPayDelegate: TinkoffPayDelegate? = nil,completionHandler: @escaping PaymentCompletionHandler instead")
    /// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
    public func presentPaymentView(on presentingViewController: UIViewController,
                                   paymentData: PaymentInitData,
                                   configuration: AcquiringViewConfiguration,
                                   acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                   tinkoffPayDelegate: TinkoffPayDelegate? = nil,
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
        switch acquiringConfiguration.paymentStage {
        case .none:
            acquiringPaymentStageConfiguration = .init(paymentStage: .`init`(paymentData: paymentData))
        case let .paymentId(paymentId):
            acquiringPaymentStageConfiguration = .init(paymentStage: .finish(paymentId: paymentId))
        }
        
        self.presentPaymentView(on: presentingViewController,
                                customerKey: paymentData.customerKey,
                                acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                                configuration: configuration,
                                tinkoffPayDelegate: tinkoffPayDelegate,
                                completionHandler: completionHandler)
    }

    /// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
    public func presentPaymentView(on presentingViewController: UIViewController,
                                   customerKey: String? = nil,
                                   acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                                   configuration: AcquiringViewConfiguration,
                                   tinkoffPayDelegate: TinkoffPayDelegate? = nil,
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        onPaymentCompletionHandler = completionHandler
        acquiringViewConfiguration = configuration
        
        var customerKey = customerKey
        var acquiringConfiguration: AcquiringConfiguration
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .`init`(paymentData):
            customerKey = paymentData.customerKey
            acquiringConfiguration = .init(paymentStage: .none)
        case let .finish(paymentId):
            acquiringConfiguration = .init(paymentStage: .paymentId(paymentId))
        }
        self.acquiringConfiguration = acquiringConfiguration

        presentAcquiringPaymentView(presentingViewController: presentingViewController,
                                    customerKey: customerKey,
                                    configuration: configuration,
                                    loadCardsOutside: false,
                                    acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                                    tinkoffPayDelegate: tinkoffPayDelegate)
        
        acquiringView?.onInitFinished = { [weak self] result in
            switch result {
            case let .success(paymentId):
                if let cardRequisites = self?.acquiringView?.cardRequisites(){
                    self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: self?.acquiringView?.infoEmail())
                }
            case let .failure(error):
                self?.onPaymentCompletionHandler?(.failure(error))
            }
        }
        
        acquiringView?.onTinkoffPayButton = { [weak self] version, paymentViewController in
            guard let self = self else { return }
            let tinkoffPayViewController = self.tinkoffPayViewController(acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                                                                         configuration: configuration,
                                                                         version: version) { [weak paymentViewController] result in
                // Закрываем модально показанный экран-плашку с ожиданием оплаты, показанный поверх AcquiringPaymentViewController
                paymentViewController?.dismiss(animated: true, completion: {
                    // Закрываем AcquiringPaymentViewController
                    (paymentViewController as? AcquiringPaymentViewController)?.closeVC(animated: true, completion: {
                        completionHandler(result)
                    })
                })
            }
            paymentViewController.present(tinkoffPayViewController, animated: true)
        }
        
        acquiringView?.onTouchButtonSBP = { [weak self] paymentViewController in
            guard let self = self else { return }
            let urlSBPViewController = self.urlSBPPaymentViewController(
                acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                configuration: configuration,
                completionHandler: { [weak paymentViewController] result in
                    // Закрываем модально показанный экран-плашку с ожиданием оплаты, показанный поверх AcquiringPaymentViewController
                    paymentViewController?.dismiss(animated: true, completion: {
                        // Закрываем AcquiringPaymentViewController
                        (paymentViewController as? AcquiringPaymentViewController)?.closeVC(animated: true, completion: {
                            completionHandler(result)
                        })
                    })
                }
            )
            paymentViewController.present(urlSBPViewController, animated: true, completion: nil)
        }
    }

    /// Оплатить на основе родительского платежа, регулярный платеж
    public func presentPaymentView(on presentingViewController: UIViewController,
                                   paymentData: PaymentInitData,
                                   parentPatmentId: Int64,
                                   configuration: AcquiringViewConfiguration,
                                   completionHandler: @escaping PaymentCompletionHandler)
    {
        self.presentingViewController = presentingViewController
        acquiringViewConfiguration = configuration
        onPaymentCompletionHandler = completionHandler

        startChargeWith(paymentData, parentPaymentId: parentPatmentId, presentingViewController: presentingViewController, configuration: configuration)
    }

    public func presentAlertView(on presentingViewController: UIViewController, title: String, icon: AcquiringAlertIconType = .success, autoCloseTime: TimeInterval = 3) {
        let alert = AcquiringAlertViewController.create()
        alert.present(on: presentingViewController, title: title, icon: icon, autoCloseTime: autoCloseTime)
    }

    // MARK: Система Быстрых Платежей

    /// Проверить есть ли возможность оплаты с помощью СБП
    public func canMakePaymentsSBP() -> Bool {
        return acquiringSdk.fpsEnabled
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

        let presentSbpActivity: (Int64) -> Void = { [weak self] paymentId in
            self?.paymentInitResponseData = PaymentInitResponseData(amount: paymentData.amount,
                                                                    orderId: paymentData.orderId,
                                                                    paymentId: paymentId)
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
                        self?.paymentInitResponseData = nil
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
            let viewTitle = L10n.TinkoffAcquiring.View.Title.payQRCode
            view.changedStatus(.initWaiting)
            self.getStaticQRCode { [weak view] response in
                switch response {
                case let .success(qrCodeSVG):
                    DispatchQueue.main.async {
                        view?.changedStatus(.qrCodeStatic(qrCode: qrCodeSVG.qrCodeData, title: viewTitle))
                    }

                case let .failure(error):
                    DispatchQueue.main.async {
                        let alertTitle = L10n.TinkoffAcquiring.Alert.Title.error

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

    public func urlSBPPaymentViewController(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                                            configuration: AcquiringViewConfiguration,
                                            completionHandler: PaymentCompletionHandler? = nil) -> UIViewController {
        let bankListViewController = sbpAssembly.banksListViewController(
            acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
            configuration: configuration)
        let paymentPollingViewController = sbpAssembly.paymentPollingViewController(content: bankListViewController,
                                                                                    configuration: configuration,
                                                                                    completionHandler: completionHandler)
        let pullableContainerViewController = PullableContainerViewController(content: paymentPollingViewController)
        
        bankListViewController.noBanksAppAvailable = { [weak pullableContainerViewController] _, paymentStatusResponse in
            let presentingViewController = pullableContainerViewController?.presentingViewController
            pullableContainerViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                let emptyViewController = self.sbpAssembly.noAvailableBanksViewController(
                    paymentStatusResponse: paymentStatusResponse,
                    paymentCompletionHandler: completionHandler
                )
                if #available(iOS 13.0, *) {
                    emptyViewController.isModalInPresentation = true
                }
                let navigationController = UINavigationController(rootViewController: emptyViewController)
                navigationController.navigationBar.applyStyle(titleColor: UIColor.asdk.dynamic.text.primary,
                                                              backgroundColor: UIColor.asdk.dynamic.background.elevation1)
                presentingViewController?.present(navigationController, animated: true, completion: nil)
            })
        }
        
        return pullableContainerViewController
    }
    
    // MARK: - TinkoffPay
    
    public func tinkoffPayViewController(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                                         configuration: AcquiringViewConfiguration,
                                         version: GetTinkoffPayStatusResponse.Status.Version,
                                         completionHandler: PaymentCompletionHandler? = nil) -> UIViewController {
        let tinkoffPayViewController = self.tinkoffPayAssembly.tinkoffPayPaymentViewController(
            acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
            tinkoffPayVersion: version
        )
        let paymentPollingViewController = self.tinkoffPayAssembly.paymentPollingViewController(
            content: tinkoffPayViewController,
            configuration: configuration,
            completionHandler: completionHandler)
        
        let pullableContainerViewController = PullableContainerViewController(content: paymentPollingViewController)
        return pullableContainerViewController
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

        let presentApplePayActivity: (Int64) -> Void = { [weak self] paymentId in
            self?.paymentInitResponseData = PaymentInitResponseData(amount: data.amount,
                                                                    orderId: data.orderId,
                                                                    paymentId: paymentId)
            self?.presentApplePayActivity(request)
        }

        presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: viewConfiguration) { [weak self] _ in
            switch acquiringConfiguration.paymentStage {
            case .none:
                self?.initPay(paymentData: data) { [weak self] response in
                    switch response {
                    case let .success(initResponse):
                        self?.paymentInitResponseData = PaymentInitResponseData(paymentInitResponse: initResponse)
                        DispatchQueue.main.async {
                            presentApplePayActivity(initResponse.paymentId)
                        }

                    case let .failure(error):
                        self?.paymentInitResponseData = nil
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
    
    // MARK: - Apple Pay Experimental
    
    public func performPaymentWithApplePay(paymentData: PaymentInitData,
                                           paymentToken: PKPaymentToken,
                                           acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
                                           completionHandler: @escaping PaymentCompletionHandler) {
        switch acquiringConfiguration.paymentStage {
        case .none:
            initPay(paymentData: paymentData) { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(initResponse):
                    self?.finishAuthorizeWithApplePayPaymentToken(paymentToken: paymentToken,
                                                                  paymentId: initResponse.paymentId,
                                                                  completionHandler: completionHandler)
                }
            }
        case let .paymentId(paymentId):
            finishAuthorizeWithApplePayPaymentToken(paymentToken: paymentToken,
                                                    paymentId: paymentId,
                                                    completionHandler: completionHandler)
        }
    }
    
    private func finishAuthorizeWithApplePayPaymentToken(paymentToken: PKPaymentToken,
                                                         paymentId: Int64,
                                                         completionHandler: @escaping PaymentCompletionHandler) {
        let sourceData = PaymentSourceData.paymentData(paymentToken.paymentData.base64EncodedString())
        let finishAuthorizeData = PaymentFinishRequestData(paymentId: paymentId,
                                                           paymentSource: sourceData,
                                                           source: "ApplePay",
                                                           route: "ACQ")
        
        finishAuthorize(requestData: finishAuthorizeData,
                        treeDSmessageVersion: "1") { result in
            switch result {
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            case let .success(response):
                DispatchQueue.main.async {
                    completionHandler(.success(response))
                }
            }
        }
    }
    
    // MARK: -

    private func presentApplePayActivity(_ request: PKPaymentRequest) {
        guard let viewController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            acquiringView?.closeVC(animated: true) {
                let error = NSError(domain: L10n.TinkoffAcquiring.Unknown.Response.status,
                                    code: 0,
                                    userInfo: nil)

                self.onPaymentCompletionHandler?(.failure(error))
            }

            return
        }

        viewController.delegate = self

        acquiringView?.presentVC(viewController, animated: true) { [] in
            // self?.acquiringView.setViewHeight(viewController.view.frame.height)
        }
    }

    private func getStaticQRCode(completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeCollectorResponse, Error>) -> Void) {
        _ = acquiringSdk.paymentInvoiceQRCodeCollector(data: PaymentInvoiceSBPSourceType.imageSVG, completionHandler: { response in
            completionHandler(response)
        })
    }

    private func presentSbpActivity(paymentId: Int64, paymentInvoiceSource: PaymentInvoiceSBPSourceType, configuration: AcquiringViewConfiguration) {
        let paymentInvoice = PaymentInvoiceQRCodeData(paymentId: paymentId, paymentInvoiceType: paymentInvoiceSource)
        _ = acquiringSdk.paymentInvoiceQRCode(data: paymentInvoice) { [weak self] response in
            switch response {
            case let .success(qrCodeResponse):
                DispatchQueue.main.async {
                    if paymentInvoiceSource == .url, let url = URL(string: qrCodeResponse.qrCodeData) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:]) { _ in
                                self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                                self?.acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: L10n.TinkoffAcquiring.Text.Status.selectingPaymentSource))
                            }
                        } else {
                            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
                            activityViewController.excludedActivityTypes = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks, .markupAsPDF]

                            activityViewController.completionWithItemsHandler = { (_: UIActivity.ActivityType?, _: Bool, _: [Any]?, _: Error?) in
                                self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                            }

                            self?.acquiringView?.presentVC(activityViewController, animated: true, completion: {
                                self?.acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: L10n.TinkoffAcquiring.Text.Status.selectingPaymentSource))
                            })
                        }
                    } else {
                        self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
                    }
                }

            case let .failure(error):
                self?.paymentInitResponseData = nil
                DispatchQueue.main.async {
                    self?.acquiringView?.changedStatus(.error(error))

                    let alertTitle = L10n.TinkoffAcquiring.Alert.Title.error
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

    private func sbpWaitingIncominPayment(paymentId: Int64, source: String, sourceType: PaymentInvoiceSBPSourceType) {
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
            acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: source, status: L10n.TinkoffAcquiring.Text.Status.waitingPayment))
        } else {
            acquiringView?.changedStatus(.paymentWaitingSBPQrCode(qrCode: source, status: L10n.TinkoffAcquiring.Text.Status.waitingPayment))
        }

        checkPaymentStatus?.fetchStatus(completionStatus: completionStatus)
    }

    // MARK: Create and Setup AcquiringViewController

    private func presentAcquiringPaymentView(
        presentingViewController: UIViewController,
        customerKey: String?,
        configuration: AcquiringViewConfiguration,
        loadCardsOutside: Bool = true,
        acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration? = nil,
        tinkoffPayDelegate: TinkoffPayDelegate? = nil,
        onPresenting: (((AcquiringView) -> Void))? = nil
    ) {
        self.presentingViewController = presentingViewController

        // create
        let modalViewController = AcquiringPaymentViewController(nibName: "AcquiringPaymentViewController",
                                                                 bundle: .uiResources)

        modalViewController.style = .init(payButtonStyle: style.bigButtonStyle,
                                          tinkoffPayButtonStyle: configuration.tinkoffPayButtonStyle)
        
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
            case let .email(value, placeholder):
                fields.append(.email(value: value, placeholder: placeholder))
                estimatedViewHeight += 64
            }
        }
        
        if configuration.featuresOptions.fpsEnabled {
            fields.append(.buttonPaySBP)
            estimatedViewHeight += 120
        }
        
        if configuration.featuresOptions.tinkoffPayEnabled {
            fields.append(.tinkoffPay)
            estimatedViewHeight += 58
        }

        modalViewController.modalMinHeight = estimatedViewHeight
        modalViewController.setCells(fields)

        modalViewController.title = configuration.viewTitle
        modalViewController.scanerDataSource = configuration.scaner
        modalViewController.alertViewHelper = configuration.alertViewHelper

        acquiringView = modalViewController
        
        var injectableCardListProvider: CardListDataProvider?

        if let key = customerKey {
            if loadCardsOutside {
                setupCardListDataProvider(for: key)
                cardListDataProvider?.update()
                // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
                // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
                // будет краш из-за того, что там необходим force unwrap
                // TODO: Отрефачить эту историю!
                modalViewController.cardListDataSourceDelegate = self
                injectableCardListProvider = nil
            } else {
                setupCardListDataProvider(for: key)
                modalViewController.cardListDataSourceDelegate = self
                injectableCardListProvider = self.cardListDataProvider
            }
        }
        
        if let acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration {
            let acquiringPaymentController = AcquiringPaymentController(
                acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                tinkoffPayController: tinkoffPayAssembly.tinkoffPayController,
                payController: PayController(sdk: acquiringSdk),
                cardListDataProvider: injectableCardListProvider
            )
            acquiringPaymentController.delegate = modalViewController
            modalViewController.acquiringPaymentController = acquiringPaymentController
        }

        modalViewController.onTouchButtonShowCardList = { [injectableCardListProvider, weak self, weak modalViewController] in
            guard let self = self,
                  let cardListProvider = injectableCardListProvider
            else { return }

            let (cardsView, module) = self.cardListAssembly.cardSelectionModule(
                cardListProvider: cardListProvider,
                configuration: configuration
            )

            module.onSelectCard = { [weak cardsView, weak modalViewController] selectedCard in
                modalViewController?.selectCard(withId: selectedCard.cardId)
                cardsView?.dismiss(animated: true)
            }

            module.onAddNewCardTap = { [weak cardsView, weak modalViewController] in
                modalViewController?.selectRequisitesInput()
                cardsView?.dismiss(animated: true)
            }

            let cardsNavigationController = UINavigationController(rootViewController: cardsView)

            if let modalViewController = modalViewController {
                modalViewController.presentVC(cardsNavigationController, animated: true)
            } else {
                self.presentingViewController?.present(cardsNavigationController, animated: true)
            }
        }

        modalViewController.onCancelPayment = { [weak self] in
            self?.cancelPayment()
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController,
                                                                  presenting: presentingViewController)
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(modalViewController,
                                         animated: true,
                                         completion: {
            _ = presentationController
            onPresenting?(modalViewController)
        })
    }

    // MARK: Payment

    private func startPay(_ initPaymentData: PaymentInitData) {
        startPaymentInitData = initPaymentData
        initPay(paymentData: initPaymentData) { [weak self] response in
            switch response {
            case let .success(initResponse):
                self?.paymentInitResponseData = PaymentInitResponseData(paymentInitResponse: initResponse)
                DispatchQueue.main.async {
                    self?.acquiringView?.changedStatus(.ready)
                }

            case let .failure(error):
                self?.paymentInitResponseData = nil
                DispatchQueue.main.async {
                    self?.acquiringView?.closeVC(animated: true) {
                        self?.onPaymentCompletionHandler?(.failure(error))
                    }
                }
            }
        } // initPay
    }

    private func initPay(paymentData: PaymentInitData, completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void) {
        acquiringView?.changedStatus(.initWaiting)
        acquiringView?.setPaymentType(paymentData.savingAsParentPayment == true ? .recurrent : .standard)
        _ = acquiringSdk.paymentInit(data: paymentData) { response in
            completionHandler(response)
        }
    }

    /// Для сценария когда при прохождении 3ds v2 произошла ошибка.
    /// Инициируем новый платеж и и завершаем его без проверки версии 3ds, те если потребуется прохождение топрохолим по версии 1.0
    private func paymentTryAgainWith3dsV1(_ data: PaymentInitData, completionHandler: @escaping PaymentCompletionHandler) {
        paymentInitResponseData = nil

        let repeatFinish: (Int64) -> Void = { [weak self] paymentId in
            if let cardRequisites = self?.acquiringView?.cardRequisites() {
                var requestData = PaymentFinishRequestData(paymentId: paymentId, paymentSource: cardRequisites)
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

        let finishPay: (Int64) -> Void = { [weak self] paymentId in
            self?.paymentInitResponseData = PaymentInitResponseData(amount: initPaymentData.amount,
                                                                    orderId: initPaymentData.orderId,
                                                                    paymentId: paymentId)
            self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: infoEmail)
            self?.acquiringView?.changedStatus(.ready)
        }

        switch acquiringConfiguration.paymentStage {
        case .none:
            initPay(paymentData: initPaymentData) { [weak self] response in
                switch response {
                case let .success(initResponse):
                    DispatchQueue.main.async {
                        finishPay(initResponse.paymentId)
                    }
                case let .failure(error):
                    self?.paymentInitResponseData = nil
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

    private func startChargeWith(_ paymentData: PaymentInitData, parentPaymentId: Int64, presentingViewController: UIViewController, configuration: AcquiringViewConfiguration) {
        var data = paymentData
        data.addPaymentData(["chargeFlag": "true"])

        _ = acquiringSdk.paymentInit(data: data) { initResponse in
            switch initResponse {
            case let .success(successInitResponse):
                self.paymentInitResponseData = PaymentInitResponseData(paymentInitResponse: successInitResponse)
                DispatchQueue.main.async {
                    let chargeData = PaymentChargeRequestData(paymentId: successInitResponse.paymentId, parentPaymentId: parentPaymentId)
                    _ = self.acquiringSdk.chargePayment(data: chargeData, completionHandler: { chargeResponse in
                        switch chargeResponse {
                        case let .success(successChargeResponse):
                            DispatchQueue.main.async { [weak self] in
                                if self?.acquiringView != nil {
                                    self?.acquiringView?.closeVC(animated: true, completion: {
                                        self?.onPaymentCompletionHandler?(.success(successChargeResponse))
                                    })
                                } else {
                                    self?.onPaymentCompletionHandler?(.success(successChargeResponse))
                                }
                            }

                        case let .failure(error):
                            if (error as NSError).code == 104 {
                                data.addPaymentData(["failMapiSessionId": "\(successInitResponse.paymentId)"])
                                data.addPaymentData(["recurringType": "12"])
                                data.savingAsParentPayment = true
                                DispatchQueue.main.async {
                                    var chargePaymentId = successInitResponse.paymentId
                                    self.presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { _ in
                                        self.acquiringView?.changedStatus(.initWaiting)
                                        self.initPay(paymentData: data, completionHandler: { initResponse in
                                            switch initResponse {
                                            case let .success(initResponseSuccess):
                                                self.paymentInitResponseData = PaymentInitResponseData(paymentInitResponse: successInitResponse)
                                                DispatchQueue.main.async { [weak self] in
                                                    chargePaymentId = initResponseSuccess.paymentId
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
                self.paymentInitResponseData = nil
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

    private func finishPay(cardRequisites: PaymentSourceData, paymentId: Int64, infoEmail: String?) {
        var requestData = PaymentFinishRequestData(paymentId: paymentId, paymentSource: cardRequisites)
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
                case let .needConfirmation3DS2AppBased(appBasedData):
                    self.tdsController.completionHandler = { response in
                        completionHandler(response)
                    }
                    self.tdsController.cancelHandler = { [weak self] in
                        if self?.acquiringView != nil {
                            self?.acquiringView?.closeVC(animated: true, completion: {
                                self?.cancelPayment()
                            })
                        } else {
                            self?.cancelPayment()
                        }
                    }
                    
                    self.tdsController.doChallenge(with: appBasedData)
                case let .done(response):
                    completionHandler(.success(response))

                case .unknown:
                    let error = NSError(domain: finishResult.errorMessage ?? L10n.TinkoffAcquiring.Unknown.Response.status,
                                        code: finishResult.errorCode,
                                        userInfo: nil)

                    completionHandler(.failure(error))
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
        _ = acquiringSdk.check3dsVersion(data: requestData, completionHandler: { checkResponse in
            switch checkResponse {
            case let .success(checkResult):
                var finistRequestData = requestData
                // сбор информации для прохождения 3DS v2
                if let tdsServerTransID = checkResult.tdsServerTransID, let threeDSMethodURL = checkResult.threeDSMethodURL {
                    
                    if self.shouldUseAppBasedThreeDSFlow {
                        self.startAppBasedFlow(checkResult: checkResult,
                                               finishRequestData: finistRequestData,
                                               completionHandler: completionHandler)
                        return
                    } else {
                        // вызываем web view для проверки девайса
                        self.threeDSMethodCheckURL(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL, notificationURL: self.acquiringSdk.confirmation3DSCompleteV2URL().absoluteString, presenter: self.acquiringView)
                        // собираем информацию о девайсе
                        let screenSize = UIScreen.main.bounds.size
                        let deviceInfo = DeviceInfoParams(cresCallbackUrl: self.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString,
                                                          languageId: self.acquiringSdk.languageKey?.rawValue ?? "ru",
                                                          screenWidth: Int(screenSize.width),
                                                          screenHeight: Int(screenSize.height))
                        finistRequestData.setDeviceInfo(info: deviceInfo)
                        finistRequestData.setThreeDSVersion(checkResult.version)
                        finistRequestData.setIpAddress(self.acquiringSdk.networkIpAddress())
                    }
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
    
    private func startAppBasedFlow(checkResult: Check3dsVersionResponse,
                                   finishRequestData: PaymentFinishRequestData,
                                   completionHandler: @escaping PaymentCompletionHandler) {
        guard let paymentSystem = checkResult.paymentSystem else {
            finishAuthorize(requestData: finishRequestData, treeDSmessageVersion: checkResult.version) { finishResponse in
                completionHandler(finishResponse)
            }
            return
        }
        
        tdsController.enrichRequestDataWithAuthParams(with: paymentSystem,
                                                      messageVersion: checkResult.version,
                                                      finishRequestData: finishRequestData) { [weak self] result in
            do {
                self?.finishAuthorize(requestData: try result.get(),
                                     treeDSmessageVersion: checkResult.version,
                                     completionHandler: completionHandler)
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    private func threeDSMethodCheckURL(tdsServerTransID: String, threeDSMethodURL: String, notificationURL: String, presenter: AcquiringView?) {
            let urlData = Checking3DSURLData(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL, notificationURL: notificationURL)
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
        if let paymentInitResponseData = paymentInitResponseData {
            let paymentResponse = PaymentStatusResponse(success: false,
                                                        errorCode: 0,
                                                        errorMessage: nil,
                                                        orderId: paymentInitResponseData.orderId,
                                                        paymentId: paymentInitResponseData.paymentId,
                                                        amount: paymentInitResponseData.amount,
                                                        status: .cancelled)
            onPaymentCompletionHandler?(.success(paymentResponse))
        } else {
            let paymentCanceledResponse = PaymentStatusResponse(success: false,
                                                                errorCode: 0,
                                                                errorMessage: L10n.TinkoffAcquiring.Alert.Message.addingCardCancel,
                                                                orderId: "",
                                                                paymentId: 0,
                                                                amount: 0,
                                                                status: .cancelled)
            onPaymentCompletionHandler?(.success(paymentCanceledResponse))
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

    private func presentRandomAmountChecking(with requestKey: String, presenter _: AcquiringView?, alertViewHelper: AcquiringAlertViewProtocol?, onCancel: @escaping (() -> Void)) {
        let viewController = RandomAmounCheckingViewController(nibName: "RandomAmounCheckingViewController", bundle: .uiResources)

        viewController.onCancel = {
            onCancel()
        }

        viewController.completeHandler = { [weak self, weak viewController] value in
            viewController?.viewWaiting.isHidden = false
            self?.acquiringSdk.checkRandomAmount(value, requestKey: requestKey) { response in
                DispatchQueue.main.async {
                    viewController?.viewWaiting.isHidden = true
                    switch response {
                    case .success:
                        viewController?.onCancel = nil
                        viewController?.dismiss(animated: true, completion: {
                            self?.onRandomAmountCheckingAddCardCompletionHandler?(response)
                        })
                    case let .failure(error):
                        viewController?.dismiss(animated: true, completion: {
                            let alertTitle = L10n.TinkoffAcquiring.Alert.Title.error
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
    
    func getCardListCard(with cardId: String) -> PaymentCard? {
        return cardListDataProvider!.item(with: cardId)
    }
    
    func getCardListCard(with parentPaymentId: Int64) -> PaymentCard? {
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
        modalViewController.style = .init(addCardButtonStyle: style.bigButtonStyle)

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

    public func cardListCard(with cardId: String) throws -> PaymentCard? {
        return try getCardListDataProvider().item(with: cardId)
    }

    public func cardListCard(with parentPaymentId: Int64) throws -> PaymentCard? {
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

    private func checkConfirmAddCard(_ confirmationResponse: FinishAddCardResponse, presenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, _ confirmationComplete: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
        switch confirmationResponse.responseStatus {
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

            presentRandomAmountChecking(with: requestKey, presenter: presenter, alertViewHelper: alertViewHelper) { [weak self] in
                self?.cancelAddCard()
            }

        case let .done(response):
            confirmationComplete(.success(response))

        case .unknown:
            let error = NSError(domain: confirmationResponse.errorMessage ?? L10n.TinkoffAcquiring.Unknown.Response.status,
                                code: confirmationResponse.errorCode, userInfo: nil)

            confirmationComplete(.failure(error))
        }
    }

    func cardListAddCard(number: String, expDate: String, cvc: String, addCardViewPresenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
        
        do {
            let cardListDataProvider = try getCardListDataProvider()
            let checkType: PaymentCardCheckType = addCardNeedSetCheckTypeHandler?() ?? .no

            cardListDataProvider.addCard(
                number: number,
                expDate: expDate,
                cvc: cvc,
                checkType: checkType.rawValue,
                confirmationHandler: { [weak self] confirmationResponse, confirmationComplete in
                    DispatchQueue.main.async {
                        self?.checkConfirmAddCard(
                           confirmationResponse,
                           presenter: addCardViewPresenter,
                           alertViewHelper: alertViewHelper,
                           confirmationComplete
                        )
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

    public func presentCardList(
        on presentingViewController: UIViewController,
        customerKey: String,
        configuration: AcquiringViewConfiguration
    ) {

        if acquiringViewConfiguration == nil {
            acquiringViewConfiguration = configuration
        }

        if self.presentingViewController == nil {
            self.presentingViewController = presentingViewController
        }

        let cardListProvider = resolveCardListDataProvider(customerKey: customerKey)

        let (view, module) = cardListAssembly.cardsPresentingModule(
            cardListProvider: cardListProvider,
            configuration: configuration
        )

        module.onAddNewCardTap = { [weak view, weak module] in
            guard let view = view else { return }

            self.presentAddCardView(
                on: view,
                customerKey: customerKey,
                configuration: configuration,
                completeHandler: { module?.addingNewCard(completedWith: $0) }
            )
        }

        let navigationController = UINavigationController(rootViewController: view)
        presentingViewController.present(navigationController, animated: true)
    }
}

extension AcquiringUISDK: PKPaymentAuthorizationViewControllerDelegate {
    // MARK: PKPaymentAuthorizationViewControllerDelegate

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            if let result = self?.finishPaymentStatusResponse {
                self?.acquiringView?.closeVC(animated: true) {
                    self?.onPaymentCompletionHandler?(result)
                }
            } else {
                self?.acquiringView?.closeVC(animated: true) {
                    self?.cancelPayment()
                }
            }
        }
    }

    public func paymentAuthorizationViewController(_: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    {
        if let paymentId = paymentInitResponseData?.paymentId {
            let paymentDataSource = PaymentSourceData.paymentData(payment.token.paymentData.base64EncodedString())
            let data = PaymentFinishRequestData(paymentId: paymentId,
                                                paymentSource: paymentDataSource,
                                                source: "ApplePay",
                                                route: "ACQ")
            
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

                self?.finishPaymentStatusResponse = finishResponse
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

            if stringValue.hasSuffix(self?.acquiringSdk.confirmation3DSTerminationURL().absoluteString ?? "") ||
                stringValue.hasSuffix(self?.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString ?? "")
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
                            let error = NSError(domain: L10n.TinkoffAcquiring.Unknown.Response.status, code: 0, userInfo: nil)
                            self?.on3DSCheckingCompletionHandler?(.failure(error))
                            self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                        })

                        return
                    }

                    // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
                    guard acquiringResponse.success else {
                        let error = NSError(domain: acquiringResponse.errorMessage ?? L10n.TinkoffAcquiring.Unknown.Error.status,
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
                            let error = NSError(domain: acquiringResponse.errorMessage ?? L10n.TinkoffAcquiring.Unknown.Error.status,
                                                code: acquiringResponse.errorCode,
                                                userInfo: try? acquiringResponse.encode2JSONObject())

                            self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                                self?.on3DSCheckingCompletionHandler?(.failure(error))
                            })

                            return
                        }

                        //
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.on3DSCheckingCompletionHandler?(.success(responseObject))
                        })
                    }

                    // data in `AddCardStatusResponse` format
                    if self?.on3DSCheckingAddCardCompletionHandler != nil {
                        guard let responseObject: AddCardStatusResponse = try? JSONDecoder().decode(AddCardStatusResponse.self, from: data) else {
                            let error = NSError(domain: acquiringResponse.errorMessage ?? L10n.TinkoffAcquiring.Unknown.Error.status,
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
