//
//  CardsService.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.09.2022.
//

import Foundation
import TinkoffASDKCore

/// Сервис для работы с картами
public protocol ICardsService {

    var customerKey: String { get }

    /// Добавление карты -> в случае успеха возвращает в .success(cardId: String) на Main Queue
    @discardableResult
    func addCard(
        card: Card,
        checkType: PaymentCardCheckType,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable

    /// Удалить карту
    /// - Returns: RemoveCardPayload where cardStatus equals to D (deleted)
    @discardableResult
    func removeCard(
        cardId: String,
        completion: @escaping (Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable

    /// Получить все карты пользователя
    @discardableResult
    func getCards(
        completion: @escaping (Result<[PaymentCard], Error>) -> Void
    ) -> Cancellable
}

// MARK: - CardsService

/// Возвращает резудьтат работы (completions) на главную очередь
public final class CardsService {

    public let customerKey: String

    // Private
    private let coreSdk: AcquiringSdk
    private let confirmationHandler: ConfirmationHandler

    public init(
        customerKey: String,
        coreSdk: AcquiringSdk,
        confirmationHandler: ConfirmationHandler
    ) {
        self.customerKey = customerKey
        self.coreSdk = coreSdk
        self.confirmationHandler = confirmationHandler
    }

    // MARK: - Private

    @discardableResult
    private func finishAddingCard(
        data: FinishAddCardData,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable {
        let finishAddCardCancellable = coreSdk.finishAddCard(
            data: data,
            completion: { [weak self] result in
                performOnMain {
                    switch result {
                    case let .success(payload):
                        self?.confirmationHandler.handleAddCardConfirmation(
                            response: payload,
                            resultHandler: completion
                        )
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        )

        return finishAddCardCancellable
    }
}

// MARK: - CardsService + ICardsService

extension CardsService: ICardsService {

    /// Добавление карты -> в случае успеха возвращает в .success(cardId: String) на Main Queue
    @discardableResult
    public func addCard(
        card: Card,
        checkType: PaymentCardCheckType,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable {
        let initAddCardData = InitAddCardData(with: checkType.rawValue, customerKey: customerKey)

        let initCardCancellable = coreSdk.initAddCard(data: initAddCardData) { [weak self] result in
            switch result {
            case let .success(addCardPayload):
                let finishAddCardData = FinishAddCardData(
                    cardNumber: card.number,
                    expDate: card.expDate,
                    cvv: card.cvc,
                    requestKey: addCardPayload.requestKey
                )

                self?.finishAddingCard(
                    data: finishAddCardData,
                    completion: completion
                )

            case let .failure(error):
                performOnMain {
                    completion(.failure(error))
                }
            }
        }

        return initCardCancellable
    }

    /// Удалить карту
    /// - Returns: RemoveCardPayload where cardStatus equals to D (deleted)
    @discardableResult
    public func removeCard(
        cardId: String,
        completion: @escaping (Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable {
        coreSdk.deactivateCard(
            data: InitDeactivateCardData(cardId: cardId, customerKey: customerKey),
            completion: { result in
                performOnMain {
                    completion(result)
                }
            }
        )
    }

    /// Получить все карты пользователя
    @discardableResult
    public func getCards(
        completion: @escaping (Result<[PaymentCard], Error>) -> Void
    ) -> Cancellable {
        coreSdk.getCardList(
            data: GetCardListData(customerKey: customerKey),
            completion: { result in
                performOnMain {
                    completion(result)
                }
            }
        )
    }
}
