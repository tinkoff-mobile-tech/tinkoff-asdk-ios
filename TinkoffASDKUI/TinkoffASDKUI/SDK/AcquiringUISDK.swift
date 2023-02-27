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

import ThreeDSWrapper
import TinkoffASDKCore
import UIKit
import WebKit

public typealias PaymentResultCompletion = (PaymentResult) -> Void

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
        public var fpsEnabled = false
        public var tinkoffPayEnabled = true

        init() {}
    }

    ///
    /// Локализация формы оплаты
    @available(*, deprecated, message: "Will be removed soon")
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

    @available(*, deprecated, message: "Will be removed soon")
    public var localizableInfo: LocalizableInfo?

    ///  Сканер
    public weak var scaner: AcquiringScanerProtocol?
    ///
    public weak var alertViewHelper: AcquiringAlertViewProtocol?
    public var alertViewEnable = true
    public var featuresOptions = FeaturesOptions()
    public var fields: [InfoFields] = []
    public var viewTitle: String?
    public var startViewHeight: CGFloat?
    public var popupStyle: PopupStyle = .dynamic
    public var tinkoffPayButtonStyle = TinkoffPayButton.DynamicStyle(lightStyle: .black, darkStyle: .white)

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

public typealias PaymentCompletionHandler = (_ result: Result<PaymentStatusResponse, Error>) -> Void
public typealias AddCardCompletionHandler = (_ result: Result<AddCardStatusResponse, Error>) -> Void

/// Сканер для реквизитов карты
public protocol AcquiringScanerProtocol: AnyObject {
    ///
    /// - Parameters:
    ///   - completion: результат сканирования, номер карты `number`, месяц `month`, год `year`
    /// - Returns: сканер UIViewController
    func presentScanner(completion: @escaping (_ number: String?, _ month: Int?, _ year: Int?) -> Void) -> UIViewController?
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

// swiftlint:disable type_body_length
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
    private var on3DSCheckingAddCardCompletionHandler: ((Result<Void, Error>) -> Void)?
    // random amount
    private var onRandomAmountCheckingAddCardCompletionHandler: AddCardCompletionHandler?
    //
    private var webViewFor3DSChecking: WKWebView?

    // data providers
    private var cardListDataProvider: CardListDataProvider?
    private var checkPaymentStatus: PaymentStatusServiceProvider?

    private let sbpBanksAssembly: ISBPBanksAssembly
    private let cardListAssembly: ICardListAssembly

    // App based threeDS
    let tdsController: TDSController
    // ThreeDS feature flag
    private let shouldUseAppBasedThreeDSFlow = false

    private weak var logger: LoggerDelegate?
    private let paymentControllerAssembly: IPaymentControllerAssembly
    private let addCardControllerAssembly: IAddCardControllerAssembly
    private let cardsControllerAssembly: ICardsControllerAssembly
    private let yandexPayButtonContainerFactoryProvider: IYandexPayButtonContainerFactoryProvider
    private let webViewAuthChallengeService: IWebViewAuthChallengeService
    private let mainFormAssembly: IMainFormAssembly
    private let addNewCardAssembly: IAddNewCardAssembly

    // MARK: Init

    public convenience init(
        configuration: AcquiringSdkConfiguration,
        uiSDKConfiguration: UISDKConfiguration = UISDKConfiguration(),
        style: Style = DefaultStyle()
    ) throws {
        let coreSDK = try AcquiringSdk(configuration: configuration)

        self.init(
            coreSDK: coreSDK,
            configuration: configuration,
            uiSDKConfiguration: uiSDKConfiguration,
            style: style
        )
    }

    init(
        coreSDK: AcquiringSdk,
        configuration: AcquiringSdkConfiguration,
        uiSDKConfiguration: UISDKConfiguration,
        style: Style = DefaultStyle()
    ) {
        acquiringSdk = coreSDK
        self.style = style

        webViewAuthChallengeService = uiSDKConfiguration.webViewAuthChallengeService ?? DefaultWebViewAuthChallengeService()

        let threeDSWebViewAssembly = ThreeDSWebViewAssembly(
            coreSDK: coreSDK,
            authChallengeService: webViewAuthChallengeService
        )

        let threeDSWebFlowAssembly = ThreeDSWebFlowControllerAssembly(
            coreSDK: coreSDK,
            threeDSWebViewAssembly: threeDSWebViewAssembly
        )

        paymentControllerAssembly = PaymentControllerAssembly(
            coreSDK: coreSDK,
            threeDSWebFlowAssembly: threeDSWebFlowAssembly,
            sdkConfiguration: configuration,
            uiSDKConfiguration: uiSDKConfiguration
        )

        addCardControllerAssembly = AddCardControllerAssembly(
            coreSDK: coreSDK,
            webFlowControllerAssembly: threeDSWebFlowAssembly,
            configuration: uiSDKConfiguration
        )

        cardsControllerAssembly = CardsControllerAssembly(
            coreSDK: coreSDK,
            addCardControllerAssembly: addCardControllerAssembly
        )

        sbpBanksAssembly = SBPBanksAssembly(
            acquiringSdk: acquiringSdk,
            sbpConfiguration: uiSDKConfiguration.sbpConfiguration
        )
        let tdsWrapper = TDSWrapperBuilder(env: configuration.serverEnvironment, language: configuration.language).build()
        let tdsCertsManager = TDSCertsManager(acquiringSdk: acquiringSdk, tdsWrapper: tdsWrapper)
        let tdsTimeoutResolver = TDSTimeoutResolver()
        tdsController = TDSController(
            acquiringSdk: acquiringSdk,
            tdsWrapper: tdsWrapper,
            tdsCertsManager: tdsCertsManager,
            tdsTimeoutResolver: tdsTimeoutResolver
        )

        logger = configuration.logger

        yandexPayButtonContainerFactoryProvider = YandexPayButtonContainerFactoryProvider(
            flowAssembly: YandexPayPaymentFlowAssembly(
                yandexPayPaymentSheetAssembly: YandexPayPaymentSheetAssembly(
                    paymentControllerAssembly: paymentControllerAssembly
                )
            ),
            methodProvider: YandexPayMethodProvider(terminalService: coreSDK)
        )

        let cardPaymentAssembly = CardPaymentAssembly(
            cardsControllerAssembly: cardsControllerAssembly,
            paymentControllerAssembly: paymentControllerAssembly
        )
        mainFormAssembly = MainFormAssembly(
            coreSDK: coreSDK,
            paymentControllerAssembly: paymentControllerAssembly,
            cardPaymentAssembly: cardPaymentAssembly,
            sbpBanksAssembly: sbpBanksAssembly
        )

        addNewCardAssembly = AddNewCardAssembly(cardsControllerAssembly: cardsControllerAssembly)

        cardListAssembly = CardListAssembly(
            cardsControllerAssembly: cardsControllerAssembly,
            addNewCardAssembly: addNewCardAssembly
        )
    }

    /// Вызывается когда пользователь привязывает карту.
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
        if let cardListDataProvider = cardListDataProvider {
            provider = cardListDataProvider.customerKey == customerKey
                ? cardListDataProvider
                : CardListDataProvider(coreSDK: acquiringSdk, customerKey: customerKey)
        } else {
            provider = CardListDataProvider(coreSDK: acquiringSdk, customerKey: customerKey)
        }

        cardListDataProvider = provider

        if statusListener == nil {
            cardListDataProvider?.dataSourceStatusListener = self
        } else {
            cardListDataProvider?.dataSourceStatusListener = statusListener
        }

        return provider
    }

    @available(*, deprecated, message: """
    Use presentPaymentView(
        on presentingViewController: UIViewController,
        acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
        configuration: AcquiringViewConfiguration,
        tinkoffPayDelegate: TinkoffPayDelegate? = nil,
        completionHandler: @escaping PaymentCompletionHandler instead
    """)
    /// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
    public func presentPaymentView(
        on presentingViewController: UIViewController,
        paymentData: PaymentInitData,
        configuration: AcquiringViewConfiguration,
        acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
        tinkoffPayDelegate: TinkoffPayDelegate? = nil,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
        switch acquiringConfiguration.paymentStage {
        case .none:
            acquiringPaymentStageConfiguration = AcquiringPaymentStageConfiguration(paymentStage: .`init`(paymentData: paymentData))
        case let .paymentId(paymentId):
            acquiringPaymentStageConfiguration = AcquiringPaymentStageConfiguration(paymentStage: .finish(paymentId: paymentId))
        }

        presentPaymentView(
            on: presentingViewController,
            customerKey: paymentData.customerKey,
            acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
            configuration: configuration,
            tinkoffPayDelegate: tinkoffPayDelegate,
            completionHandler: completionHandler
        )
    }

    /// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
    public func presentPaymentView(
        on presentingViewController: UIViewController,
        customerKey: String? = nil,
        acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
        configuration: AcquiringViewConfiguration,
        tinkoffPayDelegate: TinkoffPayDelegate? = nil,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        onPaymentCompletionHandler = completionHandler
        acquiringViewConfiguration = configuration

        var customerKey = customerKey
        var acquiringConfiguration: AcquiringConfiguration
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .`init`(paymentData):
            customerKey = paymentData.customerKey
            acquiringConfiguration = AcquiringConfiguration(paymentStage: .none)
        case let .finish(paymentId):
            acquiringConfiguration = AcquiringConfiguration(paymentStage: .paymentId(paymentId))
        }
        self.acquiringConfiguration = acquiringConfiguration

        presentAcquiringPaymentView(
            presentingViewController: presentingViewController,
            customerKey: customerKey,
            configuration: configuration,
            loadCardsOutside: false,
            acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
            tinkoffPayDelegate: tinkoffPayDelegate
        )

        acquiringView?.onInitFinished = { [weak self] result in
            switch result {
            case let .success(paymentId):
                if let cardRequisites = self?.acquiringView?.cardRequisites() {
                    self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: self?.acquiringView?.infoEmail())
                }
            case let .failure(error):
                self?.onPaymentCompletionHandler?(.failure(error))
            }
        }

        acquiringView?.onTinkoffPayButton = nil
        acquiringView?.onTouchButtonSBP = nil
    }

    /// Оплатить на основе родительского платежа, регулярный платеж
    public func presentPaymentView(
        on presentingViewController: UIViewController,
        paymentData: PaymentInitData,
        parentPatmentId: Int64,
        configuration: AcquiringViewConfiguration,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        self.presentingViewController = presentingViewController
        acquiringViewConfiguration = configuration
        onPaymentCompletionHandler = completionHandler

        startChargeWith(
            paymentData,
            parentPaymentId: parentPatmentId,
            presentingViewController: presentingViewController,
            configuration: configuration
        )
    }

    public func presentAlertView(
        on presentingViewController: UIViewController,
        title: String,
        icon: AcquiringAlertIconType = .success,
        autoCloseTime: TimeInterval = 3
    ) {
        let alert = AcquiringAlertViewController.create()
        alert.present(on: presentingViewController, title: title, icon: icon, autoCloseTime: autoCloseTime)
    }

    // MARK: Система Быстрых Платежей

    /// Проверить есть ли возможность оплаты с помощью СБП
    public func canMakePaymentsSBP() -> Bool {
        return acquiringSdk.fpsEnabled
    }

    public func presentPaymentSbpQrImage(
        on presentingViewController: UIViewController,
        paymentData: PaymentInitData,
        configuration: AcquiringViewConfiguration,
        acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        presentPaymentSbp(
            on: presentingViewController,
            paymentInvoiceSource: .imageSVG,
            paymentData: paymentData,
            configuration: configuration,
            acquiringConfiguration: acquiringConfiguration
        ) { response in
            completionHandler(response)
        }
    }

    public func presentPaymentSbpUrl(
        on presentingViewController: UIViewController,
        paymentData: PaymentInitData,
        configuration: AcquiringViewConfiguration,
        acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        presentPaymentSbp(
            on: presentingViewController,
            paymentInvoiceSource: .url,
            paymentData: paymentData,
            configuration: configuration,
            acquiringConfiguration: acquiringConfiguration
        ) { response in
            completionHandler(response)
        }
    }

    private func presentPaymentSbp(
        on presentingViewController: UIViewController,
        paymentInvoiceSource: PaymentInvoiceSBPSourceType,
        paymentData: PaymentInitData,
        configuration: AcquiringViewConfiguration,
        acquiringConfiguration: AcquiringConfiguration,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        onPaymentCompletionHandler = completionHandler
        self.acquiringConfiguration = acquiringConfiguration

        let presentSbpActivity: (Int64) -> Void = { [weak self] paymentId in
            self?.paymentInitResponseData = PaymentInitResponseData(
                amount: paymentData.amount,
                orderId: paymentData.orderId,
                paymentId: paymentId
            )
            self?.presentSbpActivity(paymentId: paymentId, paymentInvoiceSource: paymentInvoiceSource, configuration: configuration)
        }

        presentAcquiringPaymentView(
            presentingViewController: presentingViewController,
            customerKey: paymentData.customerKey,
            configuration: configuration
        ) { [weak self] _ in
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
            let viewTitle = Loc.TinkoffAcquiring.View.Title.payQRCode
            view.changedStatus(.initWaiting)
            self.getStaticQRCode { [weak view] response in
                switch response {
                case let .success(qrCodeSVG):
                    DispatchQueue.main.async {
                        view?.changedStatus(.qrCodeStatic(qrCode: qrCodeSVG.qrCodeData, title: viewTitle))
                    }

                case let .failure(error):
                    DispatchQueue.main.async {
                        let alertTitle = Loc.TinkoffAcquiring.Alert.Title.error

                        if let alert = configuration.alertViewHelper?.presentAlertView(
                            alertTitle,
                            message: error.localizedDescription,
                            dismissCompletion: nil
                        ) {
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

    // MARK: -

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
                                self?.sbpWaitingIncominPayment(
                                    paymentId: paymentId,
                                    source: qrCodeResponse.qrCodeData,
                                    sourceType: paymentInvoiceSource
                                )
                                self?.acquiringView?.changedStatus(
                                    .paymentWaitingSBPUrl(
                                        url: qrCodeResponse.qrCodeData,
                                        status: Loc.TinkoffAcquiring.Text.Status.selectingPaymentSource
                                    )
                                )
                            }
                        } else {
                            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
                            activityViewController.excludedActivityTypes = [
                                .postToWeibo,
                                .print,
                                .assignToContact,
                                .saveToCameraRoll,
                                .addToReadingList,
                                .postToFlickr,
                                .postToVimeo,
                                .postToTencentWeibo,
                                .airDrop,
                                .openInIBooks,
                                .markupAsPDF,
                            ]

                            activityViewController.completionWithItemsHandler = { (_: UIActivity.ActivityType?, _: Bool, _: [Any]?, _: Error?) in
                                self?.sbpWaitingIncominPayment(
                                    paymentId: paymentId,
                                    source: qrCodeResponse.qrCodeData,
                                    sourceType: paymentInvoiceSource
                                )
                            }

                            self?.acquiringView?.presentVC(activityViewController, animated: true, completion: {
                                self?.acquiringView?.changedStatus(
                                    .paymentWaitingSBPUrl(
                                        url: qrCodeResponse.qrCodeData,
                                        status: Loc.TinkoffAcquiring.Text.Status.selectingPaymentSource
                                    )
                                )
                            })
                        }
                    } else {
                        self?.sbpWaitingIncominPayment(
                            paymentId: paymentId,
                            source: qrCodeResponse.qrCodeData,
                            sourceType: paymentInvoiceSource
                        )
                    }
                }

            case let .failure(error):
                self?.paymentInitResponseData = nil
                DispatchQueue.main.async {
                    self?.acquiringView?.changedStatus(.error(error))

                    let alertTitle = Loc.TinkoffAcquiring.Alert.Title.error
                    if let alert = configuration.alertViewHelper?.presentAlertView(
                        alertTitle,
                        message: error.localizedDescription,
                        dismissCompletion: nil
                    ) {
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
        let completionStatus: [AcquiringStatus] = [.confirmed, .checked3ds, .refunded, .reversed, .rejected]
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
            acquiringView?.changedStatus(.paymentWaitingSBPUrl(url: source, status: Loc.TinkoffAcquiring.Text.Status.waitingPayment))
        } else {
            acquiringView?.changedStatus(.paymentWaitingSBPQrCode(qrCode: source, status: Loc.TinkoffAcquiring.Text.Status.waitingPayment))
        }

        checkPaymentStatus?.fetchStatus(completionStatus: completionStatus)
    }

    // MARK: Create and Setup AcquiringViewController

    func presentAcquiringPaymentView(
        presentingViewController: UIViewController,
        customerKey: String?,
        configuration: AcquiringViewConfiguration,
        loadCardsOutside: Bool = true,
        acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration? = nil,
        tinkoffPayDelegate: TinkoffPayDelegate? = nil,
        onPresenting: ((AcquiringView) -> Void)? = nil
    ) {
        self.presentingViewController = presentingViewController

        // create
        let modalViewController = AcquiringPaymentViewController(
            nibName: "AcquiringPaymentViewController",
            bundle: .uiResources
        )

        modalViewController.style = AcquiringPaymentViewController.Style(
            payButtonStyle: style.bigButtonStyle,
            tinkoffPayButtonStyle: configuration.tinkoffPayButtonStyle
        )

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
        modalViewController.popupStyle = configuration.popupStyle

        acquiringView = modalViewController

        var injectableCardListProvider: CardListDataProvider?

        if let key = customerKey {
            if loadCardsOutside {
                setupCardListDataProvider(for: key)
                cardListDataProvider?.update()
                // вызов setupCardListDataProvider ранее гарантирует, что cardListDataProvider будет не nil, поэтому мы можем
                // передать AcquiringUISDK как cardListDataSourceDelegate, иначе при вызове методов протокола AcquiringCardListDataSourceDelegate
                // будет краш из-за того, что там необходим force unwrap
                modalViewController.cardListDataSourceDelegate = self
                injectableCardListProvider = nil
            } else {
                setupCardListDataProvider(for: key)
                modalViewController.cardListDataSourceDelegate = self
                injectableCardListProvider = cardListDataProvider
            }
        }

        if let acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration {
            let acquiringPaymentController = AcquiringPaymentController(
                acquiringPaymentStageConfiguration: acquiringPaymentStageConfiguration,
                cardListDataProvider: injectableCardListProvider
            )
            acquiringPaymentController.delegate = modalViewController
            modalViewController.acquiringPaymentController = acquiringPaymentController
        }

        modalViewController.onCancelPayment = { [weak self] in
            self?.cancelPayment()
        }

        // present
        let presentationController = PullUpPresentationController(
            presentedViewController: modalViewController,
            presenting: presentingViewController
        )
        modalViewController.transitioningDelegate = presentationController
        presentingViewController.present(
            modalViewController,
            animated: true,
            completion: {
                _ = presentationController
                onPresenting?(modalViewController)
            }
        )
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

    public func pay(
        on presentingViewController: UIViewController,
        initPaymentData: PaymentInitData,
        cardRequisites: PaymentSourceData,
        infoEmail: String?,
        configuration: AcquiringViewConfiguration,
        acquiringConfiguration: AcquiringConfiguration = AcquiringConfiguration(),
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        self.presentingViewController = presentingViewController
        startPaymentInitData = initPaymentData
        acquiringViewConfiguration = configuration
        onPaymentCompletionHandler = completionHandler
        self.acquiringConfiguration = acquiringConfiguration

        let finishPay: (Int64) -> Void = { [weak self] paymentId in
            self?.paymentInitResponseData = PaymentInitResponseData(
                amount: initPaymentData.amount,
                orderId: initPaymentData.orderId,
                paymentId: paymentId
            )
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

    private func startChargeWith(
        _ paymentData: PaymentInitData,
        parentPaymentId: Int64,
        presentingViewController: UIViewController,
        configuration: AcquiringViewConfiguration
    ) {
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
                                    self.presentAcquiringPaymentView(
                                        presentingViewController: presentingViewController,
                                        customerKey: paymentData.customerKey,
                                        configuration: configuration
                                    ) { _ in
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
                                                self?.finishPay(
                                                    cardRequisites: cardRequisites,
                                                    paymentId: chargePaymentId,
                                                    infoEmail: self?.acquiringView?.infoEmail()
                                                )
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

    private func finishAuthorize(
        requestData: PaymentFinishRequestData,
        treeDSmessageVersion: String,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        _ = acquiringSdk.paymentFinish(data: requestData, completionHandler: { response in
            switch response {
            case let .success(finishResult):
                switch finishResult.responseStatus {
                case let .needConfirmation3DS(confirmation3DSData):
                    DispatchQueue.main.async {
                        self.on3DSCheckingCompletionHandler = { response in
                            completionHandler(response)
                        }

                        self.present3DSChecking(with: confirmation3DSData) { [weak self] in
                            self?.cancelPayment()
                        }
                    }

                case let .needConfirmation3DSACS(confirmation3DSDataACS):
                    DispatchQueue.main.async {
                        self.on3DSCheckingCompletionHandler = { response in
                            completionHandler(response)
                        }

                        self.present3DSCheckingACS(
                            with: confirmation3DSDataACS,
                            messageVersion: treeDSmessageVersion
                        ) { [weak self] in
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
                    let error = NSError(
                        domain: finishResult.errorMessage ?? Loc.TinkoffAcquiring.Unknown.Response.status,
                        code: finishResult.errorCode,
                        userInfo: nil
                    )

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
                        self.startAppBasedFlow(
                            checkResult: checkResult,
                            finishRequestData: finistRequestData,
                            completionHandler: completionHandler
                        )
                        return
                    } else {
                        // вызываем web view для проверки девайса
                        self.threeDSMethodCheckURL(
                            tdsServerTransID: tdsServerTransID,
                            threeDSMethodURL: threeDSMethodURL,
                            notificationURL: self.acquiringSdk.confirmation3DSCompleteV2URL().absoluteString,
                            presenter: self.acquiringView
                        )
                        // собираем информацию о девайсе
                        let screenSize = UIScreen.main.bounds.size
                        let deviceInfo = DeviceInfoParams(
                            cresCallbackUrl: self.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString,
                            languageId: self.acquiringSdk.languageKey?.rawValue ?? "ru",
                            screenWidth: Int(screenSize.width),
                            screenHeight: Int(screenSize.height)
                        )
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

    private func startAppBasedFlow(
        checkResult: Check3dsVersionResponse,
        finishRequestData: PaymentFinishRequestData,
        completionHandler: @escaping PaymentCompletionHandler
    ) {
        guard let paymentSystem = checkResult.paymentSystem else {
            finishAuthorize(requestData: finishRequestData, treeDSmessageVersion: checkResult.version) { finishResponse in
                completionHandler(finishResponse)
            }
            return
        }

        tdsController.enrichRequestDataWithAuthParams(
            with: paymentSystem,
            messageVersion: checkResult.version,
            finishRequestData: finishRequestData
        ) { [weak self] result in
            do {
                self?.finishAuthorize(
                    requestData: try result.get(),
                    treeDSmessageVersion: checkResult.version,
                    completionHandler: completionHandler
                )
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
                presenter?.checkDeviceFor3DSData(with: request, navigationDelegate: self)
            } else {
                self.webViewFor3DSChecking = WKWebView()
                self.webViewFor3DSChecking?.navigationDelegate = self
                self.webViewFor3DSChecking?.load(request)
            }
        }
    }

    private func cancelPayment() {
        if let paymentInitResponseData = paymentInitResponseData {
            let paymentResponse = PaymentStatusResponse(
                success: false,
                errorCode: 0,
                errorMessage: nil,
                orderId: paymentInitResponseData.orderId,
                paymentId: paymentInitResponseData.paymentId,
                amount: paymentInitResponseData.amount,
                status: .cancelled
            )
            onPaymentCompletionHandler?(.success(paymentResponse))
        } else {
            let paymentCanceledResponse = PaymentStatusResponse(
                success: false,
                errorCode: 0,
                errorMessage: Loc.TinkoffAcquiring.Alert.Message.addingCardCancel,
                orderId: "",
                paymentId: 0,
                amount: 0,
                status: .cancelled
            )
            onPaymentCompletionHandler?(.success(paymentCanceledResponse))
        }
    }

    private func cancelAddCard() {
        onRandomAmountCheckingAddCardCompletionHandler?(.success(AddCardStatusResponse(success: false, errorCode: 0)))
        on3DSCheckingAddCardCompletionHandler?(.success(()))
        // clearing
        onRandomAmountCheckingAddCardCompletionHandler = nil
        on3DSCheckingAddCardCompletionHandler = nil
    }

    fileprivate func presentWebView(load request: URLRequest, onCancel: @escaping (() -> Void)) {
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
        presentingViewController?.presentOnTop(
            viewController: navigationController,
            animated: true,
            completion: {
                onPresenting()
            }
        )
    }

    private func present3DSChecking(with data: Confirmation3DSData, onCancel: @escaping (() -> Void)) {
        guard let request = try? acquiringSdk.createConfirmation3DSRequest(data: data) else {
            return
        }

        presentWebView(load: request, onCancel: onCancel)
    }

    private func present3DSCheckingACS(
        with data: Confirmation3DSDataACS,
        messageVersion: String,
        onCancel: @escaping (() -> Void)
    ) {
        guard let request = try? acquiringSdk.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion) else {
            return
        }

        presentWebView(load: request, onCancel: onCancel)
    }

    private func presentRandomAmountChecking(
        with requestKey: String,
        alertViewHelper: AcquiringAlertViewProtocol?,
        onCancel: @escaping (() -> Void)
    ) {
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
                            let alertTitle = Loc.TinkoffAcquiring.Alert.Title.error
                            if let alert = alertViewHelper?.presentAlertView(
                                alertTitle,
                                message: error.localizedDescription,
                                dismissCompletion: nil
                            ) {
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
        presentingViewController?.presentOnTop(
            viewController: navigationController,
            animated: true
        )
    }
}

// swiftlint:enable type_body_length

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

    func cardListToDeactivateCard(
        at index: Int,
        startHandler: (() -> Void)?,
        completion: ((PaymentCard?) -> Void)?
    ) {
        let card = cardListDataProvider!.item(at: index)
        cardListDataProvider!.deactivateCard(
            cardId: card.cardId,
            startHandler: {
                startHandler?()
            },
            completeHandler: { card in
                completion?(card)
            }
        )
    }

    func cardListToAddCard(
        number: String,
        expDate: String,
        cvc: String,
        alertViewHelper: AcquiringAlertViewProtocol?,
        completeHandler: @escaping (Result<PaymentCard?, Error>) -> Void
    ) {
        cardListDataProvider!.addCard(
            number: number,
            expDate: expDate,
            cvc: cvc,
            checkType: addCardNeedSetCheckTypeHandler?() ?? .no,
            complete3DSMethodHandler: { [weak self] tdsServerTransID, threeDSMethodURL in
                guard let self = self else { return }
                self.threeDSMethodCheckURL(
                    tdsServerTransID: tdsServerTransID,
                    threeDSMethodURL: threeDSMethodURL,
                    notificationURL: self.acquiringSdk.confirmation3DSCompleteV2URL().absoluteString,
                    presenter: nil
                )
            },
            submit3DSAuthorizationHandler: { [weak self] attachPayload, tdsVersion, completion in
                self?.checkConfirmAddCard(
                    attachPayload: attachPayload,
                    tdsVersion: tdsVersion,
                    alertViewHelper: alertViewHelper,
                    completion
                )
            },
            completion: completeHandler
        )
    }

    /// Отображает экран добавления карты
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран добавления карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    public func presentAddCard(
        on presentingViewController: UIViewController,
        customerKey: String,
        onViewWasClosed: ((AddCardResult) -> Void)? = nil
    ) {
        let navigationController = addNewCardAssembly.addNewCardNavigationController(
            customerKey: customerKey,
            onViewWasClosed: onViewWasClosed
        )

        presentingViewController.present(navigationController, animated: true)
    }

    // MARK: AcquiringPaymentCardLidtDataSourceDelegate

    public enum SDKError: Error {
        case noCustomerKey
    }

    private func getCardListDataProvider() throws -> CardListDataProvider {
        guard let cardListDataProvider = cardListDataProvider else {
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
            cardListProvider.deactivateCard(
                cardId: card.cardId,
                startHandler: {
                    startHandler?()
                },
                completeHandler: { card in
                    completion?(.success(card))
                }
            )
        } catch {
            completion?(.failure(error))
        }
    }

    private func checkConfirmAddCard(
        attachPayload: AttachCardPayload,
        tdsVersion: String,
        alertViewHelper: AcquiringAlertViewProtocol?,
        _ confirmationComplete: @escaping (Result<Void, Error>) -> Void
    ) {
        switch attachPayload.attachCardStatus {
        case let .needConfirmation3DS(confirmation3DSData):
            on3DSCheckingAddCardCompletionHandler = confirmationComplete

            present3DSChecking(with: confirmation3DSData) { [weak self] in
                self?.cancelAddCard()
            }

        case let .needConfirmation3DSACS(confirmation3DSDataACS):
            on3DSCheckingAddCardCompletionHandler = { response in
                confirmationComplete(response)
            }

            present3DSCheckingACS(with: confirmation3DSDataACS, messageVersion: tdsVersion) { [weak self] in
                self?.cancelAddCard()
            }

        case let .needConfirmationRandomAmount(requestKey):
            onRandomAmountCheckingAddCardCompletionHandler = { response in
                confirmationComplete(response.map { _ in () })
            }

            presentRandomAmountChecking(with: requestKey, alertViewHelper: alertViewHelper) { [weak self] in
                self?.cancelAddCard()
            }

        case .done:
            confirmationComplete(.success(()))
        }
    }

    /// Отображает экран со списком карт
    ///
    /// На этом экране пользователь может ознакомиться со списком привязанных карт, удалить или добавить новую карту
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран добавления карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    public func presentCardList(
        on presentingViewController: UIViewController,
        customerKey: String
    ) {
        let navigationController = cardListAssembly.cardsPresentingNavigationController(customerKey: customerKey)
        presentingViewController.present(navigationController, animated: true)
    }
}

public extension AcquiringUISDK {

    // MARK: PaymentController

    /// Создает новый `IPaymentController`, с помощью которого можно совершить оплату с прохождением проверки `3DS`
    /// - Returns: IPaymentController
    func paymentController() -> IPaymentController {
        paymentControllerAssembly.paymentController()
    }

    // MARK: AddCardController

    /// Создает новый `IAddCardController`, с помощью которого можно привязать новую карту с прохождением проверки 3DS
    /// - Parameter customerKey: Идентификатор покупателя в системе продавца
    /// - Returns: IAddCardController
    func addCardController(customerKey: String) -> IAddCardController {
        addCardControllerAssembly.addCardController(customerKey: customerKey)
    }

    // MARK: CardsController

    func cardsController(customerKey: String) -> ICardsController {
        cardsControllerAssembly.cardsController(customerKey: customerKey)
    }
}

// MARK: WKNavigationDelegate

extension AcquiringUISDK: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        webViewAuthChallengeService.webView(
            webView,
            didReceive: challenge,
            completionHandler: completionHandler
        )
    }

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
                stringValue.hasSuffix(self?.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString ?? "") {
                webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerText") { value, error in
                    // debugPrint("document.getElementsByTagName('pre')[0].innerText = \(value ?? "" )")
                    guard let responseString = value as? String, let data = responseString.data(using: .utf8) else {
                        return
                    }

                    self?.webViewController?.onCancel = nil

                    // decode as a default `AcquiringResponse`
                    guard let acquiringResponse = try? JSONDecoder().decode(AcquiringResponse.self, from: data) else {
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            let error = NSError(domain: Loc.TinkoffAcquiring.Unknown.Response.status, code: 0, userInfo: nil)
                            self?.on3DSCheckingCompletionHandler?(.failure(error))
                            self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                        })

                        return
                    }

                    // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
                    guard acquiringResponse.success else {
                        let error = NSError(
                            domain: acquiringResponse.errorMessage ?? Loc.TinkoffAcquiring.Unknown.Error.status,
                            code: acquiringResponse.errorCode,
                            userInfo: try? acquiringResponse.encode2JSONObject()
                        )

                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.on3DSCheckingCompletionHandler?(.failure(error))
                            self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                        })

                        return
                    }

                    // data in `PaymentStatusResponse` format
                    if self?.on3DSCheckingCompletionHandler != nil {
                        guard let responseObject: PaymentStatusResponse = try? JSONDecoder().decode(PaymentStatusResponse.self, from: data) else {
                            let error = NSError(
                                domain: acquiringResponse.errorMessage ?? Loc.TinkoffAcquiring.Unknown.Error.status,
                                code: acquiringResponse.errorCode,
                                userInfo: try? acquiringResponse.encode2JSONObject()
                            )

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
                            let error = NSError(
                                domain: acquiringResponse.errorMessage ?? Loc.TinkoffAcquiring.Unknown.Error.status,
                                code: acquiringResponse.errorCode,
                                userInfo: try? acquiringResponse.encode2JSONObject()
                            )

                            self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                                self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
                            })

                            return
                        }

                        //
                        self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.on3DSCheckingAddCardCompletionHandler?(.success(()))
                        })
                    }
                } // getElementsByTagName('pre')
            } // termURL.hasSuffix confirmation3DSTerminationURL
        } // document.baseURI
    } // func webView didFinish
}

public extension AcquiringUISDK {
    /// Асинхронное создание фабрики `IYandexPayButtonContainerFactory`
    ///
    /// Ссылку на полученный таким образом объект можно хранить переиспользовать множество раз в различных точках приложения.
    /// - Parameters:
    ///   - configuration: Общаяя конфигурация `YandexPay`
    ///   - initializer: Абстракция для инициализации фабрики. Используется для связывания модулей `TinkoffASDKUI` и `TinkoffASDKYandexPay`
    ///   - completion: Callback с результатом создания фабрики. Вернет `Error` при сетевых ошибках или если способ оплаты через `YandexPay` недоступен для данного терминала.
    func yandexPayButtonContainerFactory(
        with configuration: YandexPaySDKConfiguration,
        initializer: IYandexPayButtonContainerFactoryInitializer,
        completion: @escaping (Result<IYandexPayButtonContainerFactory, Error>) -> Void
    ) {
        yandexPayButtonContainerFactoryProvider.yandexPayButtonContainerFactory(
            with: configuration,
            initializer: initializer,
            completion: completion
        )
    }
}

public extension AcquiringUISDK {
    func presentMainForm(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub,
        completion: @escaping PaymentResultCompletion
    ) {
        let viewController = mainFormAssembly.build(
            paymentFlow: paymentFlow,
            configuration: configuration,
            stub: stub,
            moduleCompletion: completion
        )

        presentingViewController.present(viewController, animated: true)
    }

    func presentSBPBanksList(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: @escaping PaymentResultCompletion
    ) {
        let module = sbpBanksAssembly.buildInitialModule(paymentFlow: paymentFlow, completion: completion)
        let navigation = UINavigationController.withASDKBar(rootViewController: module.view)
        presentingViewController.present(navigation, animated: true)
    }
}
