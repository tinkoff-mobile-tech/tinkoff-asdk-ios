//
//  ICardService.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.03.2023.
//

import TinkoffASDKCore

protocol ICardService {

    /// Получение всех сохраненных карт клиента
    @discardableResult
    func getCardList(
        data: GetCardListData,
        completion: @escaping (_ result: Result<[PaymentCard], Error>) -> Void
    ) -> Cancellable

    //// Удаление привязанной карты покупателя
    @discardableResult
    func removeCard(
        data: RemoveCardData,
        completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable
}
