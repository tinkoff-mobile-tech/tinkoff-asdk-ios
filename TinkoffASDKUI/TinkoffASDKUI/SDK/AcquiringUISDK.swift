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

/// Замыкание с результатом, вызываемое после закрытия экрана оплаты
public typealias PaymentResultCompletion = (PaymentResult) -> Void

/// Фасад взаимодействия с модулем `TinkoffASDKUI` для совершения платежей
public final class AcquiringUISDK {
    // MARK: Dependencies

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
    private let tinkoffPaySheetAssembly: ITinkoffPaySheetAssembly
    private let tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly

    // MARK: Init

    /// Фасад взаимодействия с модулем `TinkoffASDKUI` для совершения платежей
    /// - Parameters:
    ///   - coreSDKConfiguration: Конфигурация модуля `TinkoffASDKCore`
    ///   - uiSDKConfiguration: Конфигурация модуля `TinkoffASDKUI`
    public convenience init(
        coreSDKConfiguration: AcquiringSdkConfiguration,
        uiSDKConfiguration: UISDKConfiguration = UISDKConfiguration()
    ) throws {
        let coreSDK = try AcquiringSdk(configuration: coreSDKConfiguration)

        self.init(
            coreSDK: coreSDK,
            configuration: coreSDKConfiguration,
            uiSDKConfiguration: uiSDKConfiguration
        )
    }

    init(
        coreSDK: AcquiringSdk,
        configuration: AcquiringSdkConfiguration,
        uiSDKConfiguration: UISDKConfiguration
    ) {
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

        let tdsWrapperBuilder = TDSWrapperBuilder(
            env: configuration.serverEnvironment,
            language: configuration.language
        )

        let tdsCertsManager = TDSCertsManager(
            acquiringSdk: coreSDK,
            tdsWrapper: tdsWrapperBuilder.build()
        )

        let appBasedFlowAssembly = TDSControllerAssembly(
            sdkConfiguration: configuration,
            coreSDK: coreSDK,
            tdsWrapperBuilder: tdsWrapperBuilder,
            tdsCertsManager: tdsCertsManager,
            threeDSDeviceInfoProvider: coreSDK.threeDSDeviceInfoProvider()
        )

        paymentControllerAssembly = PaymentControllerAssembly(
            coreSDK: coreSDK,
            threeDSWebFlowAssembly: threeDSWebFlowAssembly,
            appBasedFlowControllerAssembly: appBasedFlowAssembly,
            sdkConfiguration: configuration,
            uiSDKConfiguration: uiSDKConfiguration,
            tdsCertsManager: tdsCertsManager
        )

        addCardControllerAssembly = AddCardControllerAssembly(
            coreSDK: coreSDK,
            webFlowControllerAssembly: threeDSWebFlowAssembly,
            appBasedFlowControllerAssembly: appBasedFlowAssembly,
            configuration: uiSDKConfiguration
        )

        cardsControllerAssembly = CardsControllerAssembly(
            coreSDK: coreSDK,
            addCardControllerAssembly: addCardControllerAssembly
        )

        sbpBanksAssembly = SBPBanksAssembly(
            acquiringSdk: coreSDK,
            configuration: uiSDKConfiguration
        )

        sbpQrAssembly = SBPQrAssembly(acquiringSdk: coreSDK)

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

        tinkoffPaySheetAssembly = TinkoffPaySheetAssembly(
            coreSDK: coreSDK,
            tinkoffPayAssembly: tinkoffPayAssembly,
            tinkoffPayLandingAssembly: tinkoffPayLandingAssembly
        )

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

    // MARK: PaymentController

    /// Создает новый `IPaymentController`, с помощью которого можно совершить оплату с прохождением проверки `3DS`, используя свой `UI`
    /// - Returns: IPaymentController
    public func paymentController() -> IPaymentController {
        paymentControllerAssembly.paymentController()
    }

    // MARK: AddCardController

    /// Создает новый `IAddCardController`, с помощью которого можно привязать новую карту с прохождением проверки 3DS, используя свой `UI`
    /// - Parameter customerKey: Идентификатор покупателя в системе продавца
    /// - Parameter addCardOptions: Параметры для флоу привязки карты
    /// - Returns: IAddCardController
    public func addCardController(customerKey: String, addCardOptions: AddCardOptions) -> IAddCardController {
        addCardControllerAssembly.addCardController(customerKey: customerKey, addCardOptions: addCardOptions)
    }

    // MARK: CardsController

    /// Создает новый `ICardsController`, с помощью которого можно получить список активных карт,
    /// удалить  и привязать новую карту с прохождением проверки 3DS, используя свой `UI`
    /// - Parameter customerKey: Идентификатор покупателя в системе продавца
    /// - Parameter addCardOptions: Параметры для флоу привязки карты
    /// - Returns: ICardsController
    public func cardsController(customerKey: String, addCardOptions: AddCardOptions) -> ICardsController {
        cardsControllerAssembly.cardsController(customerKey: customerKey, addCardOptions: addCardOptions)
    }

    // MARK: MainForm

    /// Отображает основную платежную форму с различными способами оплаты
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого отобразится платежная форма
    ///   - paymentFlow: Содержит тип платежа и параметры оплаты
    ///   - configuration: Конфигурация платежной формы
    ///   - cardScannerDelegate: Делегат, предоставляющий возможность отобразить карточный сканер поверх заданного экрана
    ///   - completion: Замыкание с результатом, вызываемое после закрытия экрана оплаты
    public func presentMainForm(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        cardScannerDelegate: ICardScannerDelegate? = nil,
        completion: PaymentResultCompletion? = nil
    ) {
        let viewController = mainFormAssembly.build(
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: cardScannerDelegate,
            moduleCompletion: completion
        )

        presentingViewController.present(viewController, animated: true)
    }

    // MARK: AddCard

    /// Отображает экран привязки новой карты
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран привязки карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - addCardOptions: Параметры для флоу привязки карты
    ///   - cardScannerDelegate: Делегат, предоставляющий возможность отобразить карточный сканер поверх заданного экрана
    ///   - completion: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    public func presentAddCard(
        on presentingViewController: UIViewController,
        customerKey: String,
        addCardOptions: AddCardOptions,
        cardScannerDelegate: ICardScannerDelegate? = nil,
        completion: ((AddCardResult) -> Void)? = nil
    ) {
        let navigationController = addNewCardAssembly.addNewCardNavigationController(
            customerKey: customerKey,
            addCardOptions: addCardOptions,
            cardScannerDelegate: cardScannerDelegate,
            onViewWasClosed: completion
        )

        presentingViewController.present(navigationController, animated: true)
    }

    // MARK: CardList

    /// Отображает экран со списком карт
    ///
    /// На этом экране пользователь может ознакомиться со списком привязанных карт, удалить или добавить новую карту
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран добавления карты
    ///   - customerKey: Идентификатор покупателя в системе Продавца, к которому будет привязана карта
    ///   - addCardOptions: Параметры для флоу привязки карты
    ///   - cardScannerDelegate: Делегат, предоставляющий возможность отобразить карточный сканер поверх заданного экрана
    public func presentCardList(
        on presentingViewController: UIViewController,
        customerKey: String,
        addCardOptions: AddCardOptions,
        cardScannerDelegate: ICardScannerDelegate? = nil
    ) {
        let navigationController = cardListAssembly.cardsPresentingNavigationController(
            customerKey: customerKey,
            addCardOptions: addCardOptions,
            cardScannerDelegate: cardScannerDelegate
        )
        presentingViewController.present(navigationController, animated: true)
    }

    // MARK: SBPBanksList

    /// Отображает экран со списком приложений банков, с помощью которых можно провести оплату через `Систему быстрых платежей`
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран со списком банков
    ///   - paymentFlow: Содержит тип платежа и параметры оплаты
    ///   - completion: Замыкание с результатом оплаты, вызываемое после закрытия экрана оплаты `СБП`
    public func presentSBPBanksList(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: PaymentResultCompletion? = nil
    ) {
        let module = sbpBanksAssembly.buildInitialModule(paymentFlow: paymentFlow, completion: completion)
        let navigation = UINavigationController.withElevationBar(rootViewController: module.view)
        presentingViewController.present(navigation, animated: true)
    }

    // MARK: RecurrentPayment

    /// Отображает экран, выполняющий рекуррентный платеж
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран рекуррентного платежа
    ///   - paymentFlow: Содержит тип платежа и параметры оплаты
    ///   - rebillId: Идентификатор родительского платежа, на основе которого будет произведено списание средств
    ///   - failureDelegate: Делегат, обрабатывающий ошибку списание средств при вызове `v2/Charge`.
    ///   Используется только при оплате на основе уже существующего `paymentId (PaymentFlow.finish)`.
    ///   При `PaymentFlow.full` SDK способен самостоятельно обработать полученную ошибку.
    ///   - completion: Замыкание с результатом оплаты, вызываемое после закрытия экрана рекуррентного платежа
    public func presentRecurrentPayment(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        rebillId: String,
        failureDelegate: IRecurrentPaymentFailiureDelegate? = nil,
        completion: PaymentResultCompletion? = nil
    ) {
        let viewController = recurrentPaymentAssembly.build(
            paymentFlow: paymentFlow,
            rebillId: rebillId,
            failureDelegate: failureDelegate,
            moduleCompletion: completion
        )

        presentingViewController.present(viewController, animated: true)
    }

    // MARK: TinkoffPay

    /// Отображает экран оплаты `TinkoffPay`
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран оплаты `TinkoffPay`
    ///   - paymentFlow: Содержит тип платежа и параметры оплаты
    ///   - completion: Замыкание с результатом оплаты, вызываемое после закрытия экрана `TinkoffPay`
    public func presentTinkoffPay(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: PaymentResultCompletion? = nil
    ) {
        let viewController = tinkoffPaySheetAssembly.tinkoffPaySheet(paymentFlow: paymentFlow, completion: completion)

        presentingViewController.present(viewController, animated: true)
    }

    // MARK: StaticSBPQR

    /// Отображает экран с многоразовым `QR-кодом`, отсканировав который, пользователь сможет провести оплату с помощью `Системы быстрых платежей`
    ///
    /// При данном типе оплаты SDK никак не отслеживает статус платежа
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран с `QR-кодом`
    ///   - completion: Замыкание, вызываемое при закрытии экрана с `QR-кодом`
    public func presentStaticSBPQR(
        on presentingViewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let viewController = sbpQrAssembly.buildForStaticQr(moduleCompletion: completion)
        presentingViewController.present(viewController, animated: true)
    }

    // MARK: DynamicSBPQR

    /// Отображает экран с одноразовым `QR-кодом`, отсканировав который, пользователь сможет провести оплату  с помощью `Системы быстрых платежей`
    ///
    /// При данном типе оплаты сумма и информация о платеже фиксируется, и SDK способен получить и обработать статус платежа
    /// - Parameters:
    ///   - presentingViewController: `UIViewController`, поверх которого будет отображен экран с `QR-кодом`
    ///   - paymentFlow: Содержит тип платежа и параметры оплаты
    ///   - completion: Замыкание с результатом оплаты, вызываемое после закрытия экрана с `QR-кодом`
    public func presentDynamicSBPQR(
        on presentingViewController: UIViewController,
        paymentFlow: PaymentFlow,
        completion: @escaping PaymentResultCompletion
    ) {
        let viewController = sbpQrAssembly.buildForDynamicQr(paymentFlow: paymentFlow, moduleCompletion: completion)
        presentingViewController.present(viewController, animated: true)
    }

    // MARK: YandexPayButtonContainerFactory

    /// Асинхронное создание фабрики `IYandexPayButtonContainerFactory`
    ///
    /// Ссылку на полученный таким образом объект можно хранить переиспользовать множество раз в различных точках приложения.
    /// - Parameters:
    ///   - configuration: Общаяя конфигурация `YandexPay`
    ///   - initializer: Абстракция для инициализации фабрики. Используется для связывания модулей `TinkoffASDKUI` и `TinkoffASDKYandexPay`
    ///   - completion: Callback с результатом создания фабрики. Вернет `Error` при сетевых ошибках или если способ оплаты через `YandexPay` недоступен для данного терминала.
    public func yandexPayButtonContainerFactory(
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
