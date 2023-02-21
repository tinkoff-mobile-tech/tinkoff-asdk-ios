//
//  IAddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import UIKit

protocol IAddNewCardAssembly {
    /// Создает экран добавления карты
    ///
    /// Используется в кач-ве экрана, который пушится в `UINavigationController` с экрана списка карт
    /// - Parameters:
    ///   - customerKey: Идентификатор покупателя в системе банка
    ///   - output: Объект, который будет получать события из экрана добавления карты
    /// - Returns: `UIViewController`
    func addNewCardView(
        customerKey: String,
        output: IAddNewCardPresenterOutput?
    ) -> AddNewCardViewController

    /// Создает экран добавления карты, обернутый в `UINavigationController`
    ///
    /// Используется в кач-ве самостоятельного экрана, открываемого из родительского приложения
    /// - Parameters:
    ///   - customerKey: Идентификатор покупателя в системе банка
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    /// - Returns: `UINavigationController`
    func addNewCardNavigationController(
        customerKey: String,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> UINavigationController
}
