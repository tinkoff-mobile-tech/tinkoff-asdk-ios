//
//  CardListDataProvider.swift
//  TinkoffASDKCore
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

import Foundation
import class UIKit.UIScreen

/// Состояние для сервисов и объектов которые загружаем с севера
public enum FetchStatus<ObjectType> {
    /// статус -  пустое состояние, объект только создан, данных  нет
    case unknown
    /// статус -  данные загружаются
    case loading
    /// статус -  есть данные
    case object(ObjectType)
    /// статус -  данных нет
    case empty
    /// статус -  при загрузке данных произошла ошибка
    case error(Error)
}

/// Протокол загрузки объектов
public protocol FetchServiceProtocol {
    /// Тип объектов для загрузки
    associatedtype ObjectType

    /// Статус, текущее состояние сервиса
    var fetchStatus: FetchStatus<ObjectType> { get set }

    ///
    /// - Parameters:
    ///   - handlerOnStart: блок `(() -> Void)` сигнализирует о начале загрузки, используется уведомления пользователя что данные загружаются, можно обновить ui отрисовать SkeletonView
    ///   - complete: `(ObjectType?, [Error]?)` загрузка данных завершена.
    func fetch(startHandler: (() -> Void)?, completeHandler: @escaping (ObjectType?, Error?) -> Void)
}

/// Обычно загружается массив объектов, чтобы получить доступ к dataSourrce использум протокол `FetchObjectsDataSourceProtocol`
/// Получение объектов загруженных с исползованием `FetchServiceProtocol`
public protocol FetchDataSourceProtocol: FetchServiceProtocol where ObjectType == [U] {
    // swiftlint:disable:next type_name
    associatedtype U
    /// Общее колчесво объектов
    func count() -> Int
    /// Объект по индексу
    func item(at index: Int) -> U
    /// Объект по идентификатору
    func item(with identifier: String?) -> U?
    /// Объект по идентификатору
    func item(with parentPaymentIdentifier: Int64) -> U?
    /// Все объекты
    func allItems() -> [U]
}

/// Для отслеживания состояния
public protocol CardListDataSourceStatusListener: AnyObject {
    /// Список карт обновился
    func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>)
}

public final class CardListDataProvider: FetchDataSourceProtocol {
    public typealias Submit3DSAuthorizationHandler = (
        _ payload: AttachCardPayload,
        _ threeDSVersion: String,
        _ completion: @escaping (_ result: Result<Void, Error>) -> Void
    ) -> Void

    public typealias Complete3DSMethodHandler = (_ tdsServerTransID: String, _ threeDSMethodURL: String) -> Void
    public typealias AddCardCompletion = (_ result: Result<PaymentCard?, Error>) -> Void

    public typealias ObjectType = [PaymentCard]

    public var fetchStatus: FetchStatus<[PaymentCard]> = .unknown {
        didSet {
            dataSourceStatusListener?.cardsListUpdated(fetchStatus)
        }
    }

    private let coreSDK: AcquiringSdk
    public let customerKey: String
    private var activeCards: [PaymentCard] = []
    private var dataSource: [PaymentCard] = []
    public weak var dataSourceStatusListener: CardListDataSourceStatusListener?

    public func update() {
        switch fetchStatus {
        case .loading:
            break
        default:
            fetch(startHandler: nil) { _, _ in }
        }
    }

    public init(coreSDK: AcquiringSdk, customerKey: String) {
        self.coreSDK = coreSDK
        self.customerKey = customerKey
    }

    // MARK: Card List

    public func addCard(
        number: String,
        expDate: String,
        cvc: String,
        checkType: PaymentCardCheckType,
        complete3DSMethodHandler: @escaping Complete3DSMethodHandler,
        submit3DSAuthorizationHandler: @escaping Submit3DSAuthorizationHandler,
        completion: @escaping AddCardCompletion
    ) {
        let options = AddCardOptions(pan: number, validThru: expDate, cvc: cvc, checkType: checkType)

        let complete3DSMethodHandlerDecorator: Complete3DSMethodHandler = { tdsServerTransID, threeDSMethodURL in
            DispatchQueue.main.async { complete3DSMethodHandler(tdsServerTransID, threeDSMethodURL) }
        }

        let submit3DSAuthorizationHandlerDecorator: Submit3DSAuthorizationHandler = { submitResult, tdsVersion, completion in
            DispatchQueue.main.async {
                submit3DSAuthorizationHandler(submitResult, tdsVersion, completion)
            }
        }

        let completionDecorator: AddCardCompletion = { result in
            DispatchQueue.main.async { completion(result) }
        }

        _addCard(
            options: options,
            complete3DSMethodHandler: complete3DSMethodHandlerDecorator,
            submit3DSAuthorizationHandler: submit3DSAuthorizationHandlerDecorator,
            completion: completionDecorator
        )
    }

    public func deactivateCard(cardId: String, startHandler: (() -> Void)?, completeHandler: @escaping (PaymentCard?) -> Void) {
        startHandler?()

        coreSDK.removeCard(data: RemoveCardData(cardId: cardId, customerKey: customerKey)) { [weak self] result in
            var status: FetchStatus<[PaymentCard]> = .loading
            var deactivatedCard: PaymentCard?
            switch result {
            case let .failure(error):
                status = FetchStatus.error(error)
            case let .success(cardResponse):
                if let cards = self?.dataSource.map({ card -> PaymentCard in
                    if card.cardId == cardResponse.cardId {
                        var deactivated = card
                        deactivated.status = .deleted
                        deactivatedCard = deactivated
                        return deactivated
                    }

                    return card
                }) {
                    self?.dataSource = cards
                }

                self?.activeCards = self?.dataSource.filter { card -> Bool in
                    card.status == .active
                } ?? []

                if let cards = self?.activeCards, cards.isEmpty == false {
                    status = FetchStatus.object(cards)
                } else {
                    status = FetchStatus.empty
                }
            }

            DispatchQueue.main.async {
                self?.fetchStatus = status
                completeHandler(deactivatedCard)
            }
        }
    }

    // MARK: FetchDataSourceProtocol

    public func fetch(startHandler: (() -> Void)?, completeHandler: @escaping ([PaymentCard]?, Error?) -> Void) {
        fetchStatus = .loading
        DispatchQueue.main.async { startHandler?() }

        coreSDK.getCardList(data: GetCardListData(customerKey: customerKey)) { result in
            var status: FetchStatus<[PaymentCard]> = .loading
            var responseError: Error?
            switch result {
            case let .failure(error):
                responseError = error
                status = FetchStatus.error(error)
            case let .success(cards):
                self.dataSource = cards
                let activeCards = cards.filter { $0.status == .active }
                self.activeCards = activeCards

                if activeCards.isEmpty {
                    status = FetchStatus.empty
                } else {
                    status = FetchStatus.object(activeCards)
                }
            }

            DispatchQueue.main.async {
                self.fetchStatus = status
                completeHandler(self.activeCards, responseError)
            }
        }
    }

    public func count() -> Int {
        return activeCards.count
    }

    public func item(at index: Int) -> PaymentCard {
        return activeCards[index]
    }

    public func item(with identifier: String?) -> PaymentCard? {
        return dataSource.first { card -> Bool in
            card.cardId == identifier
        }
    }

    public func item(with parentPaymentId: Int64) -> PaymentCard? {
        return dataSource.first { card -> Bool in
            if let cardParentPaymentId = card.parentPaymentId {
                return parentPaymentId == cardParentPaymentId
            }

            return false
        }
    }

    public func allItems() -> [PaymentCard] {
        return activeCards
    }
}

// MARK: - CardListDataProvider + Add Card Flow

private extension CardListDataProvider {
    struct AddCardOptions {
        let pan: String
        let validThru: String
        let cvc: String
        let checkType: PaymentCardCheckType
    }

    private enum AddCardError: LocalizedError {
        case missingPaymentId

        var errorDescription: String? {
            switch self {
            case .missingPaymentId:
                return "`paymentId` is required in the `AddCard` response when `checkType` is `3DS`, `3DSHOLD` or `HOLD`"
            }
        }
    }

    func _addCard(
        options: AddCardOptions,
        complete3DSMethodHandler: @escaping Complete3DSMethodHandler,
        submit3DSAuthorizationHandler: @escaping Submit3DSAuthorizationHandler,
        completion: @escaping AddCardCompletion
    ) {
        coreSDK.addCard(data: AddCardData(with: options.checkType, customerKey: customerKey)) { result in
            switch result {
            case let .success(payload):
                self.check3DSVersionIfNeededAndAttachCard(
                    options: options,
                    addCardPayload: payload,
                    complete3DSMethodHandler: complete3DSMethodHandler,
                    submit3DSAuthorizationHandler: submit3DSAuthorizationHandler,
                    completion: completion
                )
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func check3DSVersionIfNeededAndAttachCard(
        options: AddCardOptions,
        addCardPayload: AddCardPayload,
        complete3DSMethodHandler: @escaping Complete3DSMethodHandler,
        submit3DSAuthorizationHandler: @escaping Submit3DSAuthorizationHandler,
        completion: @escaping (Result<PaymentCard?, Error>) -> Void
    ) {
        switch options.checkType {
        case .check3DS, .hold3DS:
            guard let paymentId = addCardPayload.paymentId else {
                return completion(.failure(AddCardError.missingPaymentId))
            }

            let check3DSVersionData = Check3DSVersionData(
                paymentId: paymentId,
                paymentSource: .cardNumber(number: options.pan, expDate: options.validThru, cvv: options.cvc)
            )

            coreSDK.check3DSVersion(data: check3DSVersionData) { check3DSResult in
                switch check3DSResult {
                case let .success(check3DSPayload):
                    var deviceData: DeviceInfoParams?

                    if let tdsServerTransID = check3DSPayload.tdsServerTransID,
                       let threeDSMethodURL = check3DSPayload.threeDSMethodURL {
                        complete3DSMethodHandler(tdsServerTransID, threeDSMethodURL)
                        deviceData = self.coreSDK.threeDSDeviceParamsProvider(screenSize: UIScreen.main.bounds.size).deviceInfoParams
                    }

                    self.attachCard(
                        options: options,
                        addCardPayload: addCardPayload,
                        tdsVersion: check3DSPayload.version,
                        deviceData: deviceData,
                        submit3DSAuthorizationHandler: submit3DSAuthorizationHandler,
                        completion: completion
                    )
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        case .no, .hold:
            attachCard(
                options: options,
                addCardPayload: addCardPayload,
                tdsVersion: "1.0.0",
                deviceData: nil,
                submit3DSAuthorizationHandler: submit3DSAuthorizationHandler,
                completion: completion
            )
        }
    }

    private func attachCard(
        options: AddCardOptions,
        addCardPayload: AddCardPayload,
        tdsVersion: String,
        deviceData: DeviceInfoParams?,
        submit3DSAuthorizationHandler: @escaping Submit3DSAuthorizationHandler,
        completion: @escaping AddCardCompletion
    ) {
        let attachData = AttachCardData(
            cardNumber: options.pan,
            expDate: options.validThru,
            cvv: options.cvc,
            requestKey: addCardPayload.requestKey,
            deviceData: deviceData
        )

        coreSDK.attachCard(data: attachData) { result in
            switch result {
            case let .success(attachPayload):
                self.submit3DSAuthorization(
                    attachPayload: attachPayload,
                    tdsVersion: tdsVersion,
                    submit3DSAuthorizationHandler: submit3DSAuthorizationHandler,
                    completion: completion
                )
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func submit3DSAuthorization(
        attachPayload: AttachCardPayload,
        tdsVersion: String,
        submit3DSAuthorizationHandler: @escaping Submit3DSAuthorizationHandler,
        completion: @escaping AddCardCompletion
    ) {

        submit3DSAuthorizationHandler(attachPayload, tdsVersion) { submitResult in
            switch submitResult {
            case .success:
                self.resolveAddedCard(withCardId: attachPayload.cardId, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func resolveAddedCard(withCardId cardId: String?, completion: @escaping AddCardCompletion) {
        let oldActiveCardIds = activeCards.map(\.cardId)

        fetch(startHandler: nil) { _, error in
            if let error = error {
                return completion(.failure(error))
            }

            if let card = cardId.flatMap({ self.item(with: $0) }) {
                completion(.success(card))
            } else {
                let card = self.activeCards.first { !oldActiveCardIds.contains($0.cardId) }
                completion(.success(card))
            }
        }
    }
}
