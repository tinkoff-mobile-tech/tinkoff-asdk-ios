//
//  ICardListPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardListPresenterOutput: AnyObject {
    /// Уведомляет об обновлении списка карт
    ///
    /// Этот метод вызывается при получении списка карт, если при инициализации модуля не были переданы карты;
    /// при удалении карты;
    /// при привязке новой карты в сценарии управления картами
    /// - Parameter cards: Обновленный список карт
    func cardList(didUpdate cards: [PaymentCard])

    /// Уведомляет о том, что пользователь выбрал карту, и модуль вот-вот закроется
    ///
    /// Вызывается только в сценарии оплаты по карте
    /// - Parameter card: Карта, выбранная пользователем
    func cardList(willCloseAfterSelecting card: PaymentCard)
}
