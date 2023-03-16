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
public typealias PaymentCompletionHandler = (_ result: Result<PaymentStatusResponse, Error>) -> Void

public class AcquiringUISDK: NSObject {

    public var acquiringSdk: AcquiringSdk
    private let style: Style
    private weak var cardsListView: CardListDataSourceStatusListener?

    private var cardListDataProvider: CardListDataProvider?
    let tdsController: TDSController

    private let paymentControllerAssembly: IPaymentControllerAssembly
    private let cardsControllerAssembly: ICardsControllerAssembly
    private let tinkoffPayAssembly: ITinkoffPayAssembly
    private let addCardControllerAssembly: IAddCardControllerAssembly
    private let yandexPayButtonContainerFactoryProvider: IYandexPayButtonContainerFactoryProvider
    private let webViewAuthChallengeService: IWebViewAuthChallengeService
    private let mainFormAssembly: IMainFormAssembly
    private let addNewCardAssembly: IAddNewCardAssembly
    private let sbpBanksAssembly: ISBPBanksAssembly
    private let sbpQrAssembly: ISBPQrAssembly
    private let cardListAssembly: ICardListAssembly
    private let recurrentPaymentAssembly: IRecurrentPaymentAssembly
    private let tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly

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

        lazy var defaultChallengeService = DefaultWebViewAuthChallengeService(certificateValidator: CertificateValidator.shared)
        webViewAuthChallengeService = uiSDKConfiguration.webViewAuthChallengeService ?? defaultChallengeService

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

        sbpQrAssembly = SBPQrAssembly(acquiringSdk: acquiringSdk)

        let tdsWrapper = TDSWrapperBuilder(env: configuration.serverEnvironment, language: configuration.language).build()
        let tdsCertsManager = TDSCertsManager(acquiringSdk: acquiringSdk, tdsWrapper: tdsWrapper)
        let tdsTimeoutResolver = TDSTimeoutResolver()
        tdsController = TDSController(
            acquiringSdk: acquiringSdk,
            tdsWrapper: tdsWrapper,
            tdsCertsManager: tdsCertsManager,
            tdsTimeoutResolver: tdsTimeoutResolver
        )

        yandexPayButtonContainerFactoryProvider = YandexPayButtonContainerFactoryProvider(
            flowAssembly: YandexPayPaymentFlowAssembly(
                yandexPayPaymentSheetAssembly: YandexPayPaymentSheetAssembly(
                    paymentControllerAssembly: paymentControllerAssembly
                )
            ),
            methodProvider: YandexPayMethodProvider(terminalService: coreSDK)
        )

        addNewCardAssembly = AddNewCardAssembly(cardsControllerAssembly: cardsControllerAssembly)

        cardListAssembly = CardListAssembly(
            paymentControllerAssembly: paymentControllerAssembly,
            cardsControllerAssembly: cardsControllerAssembly,
            addNewCardAssembly: addNewCardAssembly
        )

        recurrentPaymentAssembly = RecurrentPaymentAssembly(
            acquiringSdk: coreSDK,
            paymentControllerAssembly: paymentControllerAssembly,
            cardsControllerAssembly: cardsControllerAssembly
        )

        let cardPaymentAssembly = CardPaymentAssembly(
            cardsControllerAssembly: cardsControllerAssembly,
            paymentControllerAssembly: paymentControllerAssembly,
            cardListAssembly: cardListAssembly
        )

        tinkoffPayAssembly = TinkoffPayAssembly(coreSDK: coreSDK, configuration: uiSDKConfiguration)

        tinkoffPayLandingAssembly = TinkoffPayLandingAssembly(authChallengeService: webViewAuthChallengeService)

        mainFormAssembly = MainFormAssembly(
            coreSDK: coreSDK,
            paymentControllerAssembly: paymentControllerAssembly,
            cardsControllerAssembly: cardsControllerAssembly,
            tinkoffPayAssembly: tinkoffPayAssembly,
            tinkoffPayLandingAssembly: tinkoffPayLandingAssembly,
            cardListAssembly: cardListAssembly,
            cardPaymentAssembly: cardPaymentAssembly,
            sbpBanksAssembly: sbpBanksAssembly
        )
    }

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
}

extension AcquiringUISDK: CardListDataSourceStatusListener {
    // MARK: CardListDataSourceStatusListener

    public func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>) {
        cardsListView?.cardsListUpdated(status)
    }
}

public extension AcquiringUISDK {
    enum SDKError: Error {
        case noCustomerKey
    }

    private func getCardListDataProvider() throws -> CardListDataProvider {
        guard let cardListDataProvider = cardListDataProvider else {
            throw SDKError.noCustomerKey
        }
        return cardListDataProvider
    }

    func cardListNumberOfCards() throws -> Int {
        return try getCardListDataProvider().count()
    }

    func cardListReloadData() throws {
        return try getCardListDataProvider().update()
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
        completion: PaymentResultCompletion? = nil
    ) {
        let viewController = mainFormAssembly.build(
            paymentFlow: paymentFlow,
            configuration: configuration,
            moduleCompletion: completion
        )

        presentingViewController.present(viewController, animated: true)
    }

    /// Отображает экран добавления карты
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран добавления карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    func presentAddCard(
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

    /// Отображает экран со списком карт
    ///
    /// На этом экране пользователь может ознакомиться со списком привязанных карт, удалить или добавить новую карту
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран добавления карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    func presentCardList(
        on presentingViewController: UIViewController,
        customerKey: String
    ) {
        let navigationController = cardListAssembly.cardsPresentingNavigationController(customerKey: customerKey)
        presentingViewController.present(navigationController, animated: true)
    }

    func presentSBPBanksList(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: @escaping PaymentResultCompletion
    ) {
        let module = sbpBanksAssembly.buildInitialModule(paymentFlow: paymentFlow, completion: completion)
        let navigation = UINavigationController.withElevationBar(rootViewController: module.view)
        presentingViewController.present(navigation, animated: true)
    }

    func presentRecurrentPayment(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        amount: Int64,
        rebillId: String,
        failureDelegate: IRecurrentPaymentFailiureDelegate?,
        completion: @escaping PaymentResultCompletion
    ) {
        let viewController = recurrentPaymentAssembly.build(
            paymentFlow: paymentFlow,
            amount: amount,
            rebillId: rebillId,
            failureDelegate: failureDelegate,
            moduleCompletion: completion
        )

        presentingViewController.present(viewController, animated: true)
    }

    func presentStaticQr(
        on presentingViewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let viewController = sbpQrAssembly.buildForStaticQr(moduleCompletion: completion)
        presentingViewController.present(viewController, animated: true)
    }

    func presentDynamicQr(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: @escaping PaymentResultCompletion
    ) {
        let viewController = sbpQrAssembly.buildForDynamicQr(paymentFlow: paymentFlow, moduleCompletion: completion)
        presentingViewController.present(viewController, animated: true)
    }
}
