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
    ///
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
public protocol CardListDataSourceStatusListener: class {
    /// Список карт обновился
    func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>)
}

public final class CardListDataProvider: FetchDataSourceProtocol {
    public typealias ObjectType = [PaymentCard]

    public var fetchStatus: FetchStatus<[PaymentCard]> = .unknown {
        didSet {
            dataSourceStatusListener?.cardsListUpdated(fetchStatus)
        }
    }

    var queryStatus: Cancellable?

    private var activeCards: [PaymentCard] = []
    private var dataSource: [PaymentCard] = []
    private weak var sdk: AcquiringSdk?
    public private(set) var customerKey: String!
    public weak var dataSourceStatusListener: CardListDataSourceStatusListener?

    public func update() {
        switch fetchStatus {
        case .loading:
            break
        default:
            fetch(startHandler: nil) { _, _ in }
        }
    }

    public init(sdk: AcquiringSdk?, customerKey: String) {
        self.sdk = sdk
        self.customerKey = customerKey
    }

    // MARK: Card List

    public func addCard(number: String, expDate: String, cvc: String, checkType: String,
                        confirmationHandler: @escaping ((_ result: AttachCardPayload, _ confirmationComplete: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void) -> Void),
                        completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void)
    {
        // Step 1 init
        let initAddCardData = InitAddCardData(with: checkType, customerKey: customerKey)
        queryStatus = sdk?.addCardInit(data: initAddCardData, completionHandler: { [weak self] responseInit in
            switch responseInit {
            case let .failure(error):
                DispatchQueue.main.async { completeHandler(.failure(error)) }
            case let .success(initAddCardResponse):
                // Step 2 finish
                let finishData = FinishAddCardData(cardNumber: number, expDate: expDate, cvv: cvc, requestKey: initAddCardResponse.requestKey)
                self?.queryStatus = self?.sdk?.addCardFinish(data: finishData, completionHandler: { responseFinish in
                    switch responseFinish {
                    case let .failure(error):
                        DispatchQueue.main.async { completeHandler(.failure(error)) }
                    case let .success(finishAddCardResponse):
                        // Step 3 complete
                        confirmationHandler(finishAddCardResponse) { completionResponse in
                            switch completionResponse {
                            case let .failure(error):
                                completeHandler(.failure(error))
                            case let .success(confirmResponse):
                                if let cardId = confirmResponse.cardId {
                                    self?.fetch(startHandler: nil, completeHandler: { _, _ in
                                        if let card = self?.item(with: cardId) {
                                            completeHandler(.success(card))
                                        } else if let card = self?.activeCards.last {
                                            completeHandler(.success(card))
                                        }
                                    }) // fetch catrs list
                                } else {
                                    completeHandler(.success(nil))
                                }
                            }
                        } // confirmationHandler
                    }
                }) // сardListAddCardFinish
            }
        }) // сardListAddCardInit
    }

    public func deactivateCard(cardId: String, startHandler: (() -> Void)?, completeHandler: @escaping (PaymentCard?) -> Void) {
        let initData = InitDeactivateCardData(cardId: cardId, customerKey: customerKey)

        startHandler?()

        queryStatus = sdk?.deactivateCard(data: initData, completionHandler: { [weak self] response in
            var status: FetchStatus<[PaymentCard]> = .loading
            var deactivatedCard: PaymentCard?
            switch response {
            case let .failure(error):
                status = FetchStatus.error(error)
            case let .success(cardResponse):
                if let cards = self?.dataSource.map({ (card) -> PaymentCard in
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

                self?.activeCards = self?.dataSource.filter { (card) -> Bool in
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
        })
    }

    // MARK: FetchDataSourceProtocol

    public func fetch(startHandler: (() -> Void)?, completeHandler: @escaping ([PaymentCard]?, Error?) -> Void) {
        fetchStatus = .loading
        DispatchQueue.main.async { startHandler?() }

        let initGetCardListData = GetCardListData(customerKey: customerKey)
        queryStatus = sdk?.сardList(data: initGetCardListData, completionHandler: { [weak self] response in
            var status: FetchStatus<[PaymentCard]> = .loading
            var responseError: Error?
            switch response {
            case let .failure(error):
                responseError = error
                status = FetchStatus.error(error)
            case let .success(cards):
                self?.dataSource = cards
                let activeCards = cards.filter { (card) -> Bool in
                    card.status == .active
                }
                self?.activeCards = activeCards

                if activeCards.isEmpty {
                    status = FetchStatus.empty
                } else {
                    status = FetchStatus.object(activeCards)
                }
            }

            DispatchQueue.main.async {
                self?.fetchStatus = status
                completeHandler(self?.activeCards, responseError)
            }
        })
    }

    public func count() -> Int {
        return activeCards.count
    }

    public func item(at index: Int) -> PaymentCard {
        return activeCards[index]
    }

    public func item(with identifier: String?) -> PaymentCard? {
        return dataSource.first { (card) -> Bool in
            card.cardId == identifier
        }
    }

    public func item(with parentPaymentId: Int64) -> PaymentCard? {
        return dataSource.first { (card) -> Bool in
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
