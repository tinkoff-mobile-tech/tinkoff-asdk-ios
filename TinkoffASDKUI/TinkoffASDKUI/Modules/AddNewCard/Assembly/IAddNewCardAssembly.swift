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
    ///   - customerKey: Идентификатор покупателя в системе Продавца
    ///   - output: Объект, который будет получать события из экрана добавления карты
    ///   - cardScannerDelegate: Объект, который принимает решение какой экран показать в случае если нажали на кнопку сканера карты
    /// - Returns: `UIViewController`
    func addNewCardView(
        customerKey: String,
        addCardOptions: AddCardOptions,
        output: IAddNewCardPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> AddNewCardViewController

    /// Создает экран добавления карты, обернутый в `UINavigationController`
    ///
    /// Используется в кач-ве самостоятельного экрана, открываемого из родительского приложения
    /// - Parameters:
    ///   - customerKey: Идентификатор покупателя в системе Продавца
    ///   - cardScannerDelegate: Объект, который принимает решение какой экран показать в случае если нажали на кнопку сканера карты
    ///   - onViewWasClosed: Замыкание с результатом привязки карты, которое будет вызвано на главном потоке после закрытия экрана
    /// - Returns: `UINavigationController`
    func addNewCardNavigationController(
        customerKey: String,
        addCardOptions: AddCardOptions,
        cardScannerDelegate: ICardScannerDelegate?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> UINavigationController
}
