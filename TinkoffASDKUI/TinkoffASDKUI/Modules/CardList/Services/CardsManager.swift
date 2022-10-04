//
//  CardsManager.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 03.10.2022.
//

import TinkoffASDKCore

public protocol ErrorHandler {
    func handle(error: Error)
}

/// Предназначен для работы с картами
/// прокси для запросов и хранение данных карт / датасорс
public protocol ICardsManager: ICardsListDataSource {

    /// возможно в будущем удалим, пока сделано для паблик конформа функционала сдк
    func getCustomerKey() throws -> String

    // Проксируют cardsService
    func getCards(
        completion: ((Result<[PaymentCard], Error>) -> Void)?
    )

    /// Добавить карту
    /// - Parameters:
    ///   - completion: Result where success is cardId: String
    func addCard(
        _ card: Card,
        checkType: PaymentCardCheckType,
        completion: ((Result<String, Error>) -> Void)?
    )

    /// Удалить карту
    func removeCard(
        cardId: String,
        completion: ((Result<RemoveCardPayload, Error>) -> Void)?
    )

    // Для работы с подписчиками
    func addListener(_ listener: CardListDataSourceStatusListener)
    func removeListener(_ listener: CardListDataSourceStatusListener)
}

public final class CardsManager {

    // MARK: - Dependencies

    // must be not nill in order to work
    private let cardsService: ICardsService?

    // MARK: - Private

    private let errorHandler: ErrorHandler?

    // MARK: - Internal Data

    private var cards: [PaymentCard] = []
    private var fetchStatus: FetchStatus<[PaymentCard]> = .empty {
        didSet {
            notifyListeners(status: fetchStatus)
        }
    }

    private var activeCards: [PaymentCard] {
        cards.filter { $0.status == .active }
    }

    private var listeners: WeakArray<CardListDataSourceStatusListener> = []

    // MARK: - Init

    public init(cardsService: ICardsService?, errorHandler: ErrorHandler?) {
        assert(cardsService != nil, "Must not be nil")
        self.cardsService = cardsService
        self.errorHandler = errorHandler
    }

    // MARK: - Private

    private func shouldStartLoading() -> Bool {
        var shouldStartLoading: Bool

        switch fetchStatus {
        case .loading:
            shouldStartLoading = false
        default:
            shouldStartLoading = true
        }

        return shouldStartLoading
    }

    private func notifyListeners(status: FetchStatus<[PaymentCard]>) {
        listeners.forEach {
            $0()?.cardsListUpdated(status)
        }
    }
}

// MARK: - CardsManager + ICardsManager

extension CardsManager: ICardsManager {

    public func getCustomerKey() throws -> String {
        if let customerKey = cardsService?.customerKey {
            return customerKey
        } else {
            throw AcquiringUISDK.SDKError.noCustomerKey
        }
    }

    public func getCards(completion: ((Result<[PaymentCard], Error>) -> Void)?) {
        guard shouldStartLoading() else { return }

        fetchStatus = .loading
        cardsService?.getCards { [weak self] result in
            switch result {
            case let .success(cards):
                self?.cards = cards
                self?.fetchStatus = .object(cards)
            case let .failure(error):
                self?.errorHandler?.handle(error: error)
                self?.fetchStatus = .error(error)
            }

            completion?(result)
        }
    }

    public func addCard(
        _ card: Card,
        checkType: PaymentCardCheckType,
        completion: ((Result<String, Error>) -> Void)?
    ) {
        cardsService?.addCard(
            card: card,
            checkType: checkType,
            completion: { completion?($0) }
        )
    }

    public func removeCard(
        cardId: String,
        completion: ((Result<RemoveCardPayload, Error>) -> Void)?
    ) {
        cardsService?.removeCard(
            cardId: cardId,
            completion: { completion?($0) }
        )
    }

    public func addListener(_ listener: CardListDataSourceStatusListener) {
        listeners.append { [weak listener] in
            listener
        }
    }

    public func removeListener(_ listener: CardListDataSourceStatusListener) {
        listeners.removeAll { closure in
            closure() === listener
        }
    }
}

// MARK: - CardsManager + ICardsListDataSource

extension CardsManager: ICardsListDataSource {

    /// Количество доступных, активных карт
    public func getNumberOfActiveCards() -> Int {
        activeCards.count
    }

    /// Статус обновления списока карт
    public func getCardsListFetchStatus() -> FetchStatus<[PaymentCard]> {
        fetchStatus
    }

    /// Получить карту
    public func getCard(at index: Int) -> PaymentCard {
        activeCards[index]
    }

    /// Получить карту по cardId
    public func getCard(with cardId: String) -> PaymentCard? {
        activeCards.first(where: { $0.cardId == cardId })
    }

    /// Получить карту по parentPaymentId
    public func getCard(with parentPaymentId: Int64) -> PaymentCard? {
        activeCards.first(where: { $0.parentPaymentId == parentPaymentId })
    }

    /// Получить все карты
    public func getActiveCards() -> [PaymentCard] {
        activeCards
    }

    /// Перезагрузить, обновить список карт
    public func cardListReload() {
        getCards(completion: nil)
    }
}
