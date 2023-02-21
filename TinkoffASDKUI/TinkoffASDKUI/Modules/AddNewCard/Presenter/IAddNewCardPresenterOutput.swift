//
//  IAddNewCardPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import Foundation

protocol IAddNewCardPresenterOutput: AnyObject {
    /// Вызывается сразу при получении результата привязки карты на экране `AddNewCard`
    ///
    /// Потенциально может быть вызван несколько раз, поскольку при получении ошибки на экране `AddNewCard`
    /// пользователь имеет возможность перезапустить процесс привязки карты.
    /// По этой же причине вызов метода не всегда может означать скорое закрытие экрана `AddNewCard`
    func addNewCardDidReceive(result: AddCardResult)

    /// Вызывается единожды сразу после завершения анимации закрытия экрана
    func addNewCardWasClosed(with result: AddCardResult)
}

extension IAddNewCardPresenterOutput {
    func addNewCardDidReceive(result: AddCardResult) {}
    func addNewCardWasClosed(with result: AddCardResult) {}
}
