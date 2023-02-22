//
//  ICardListAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import UIKit

/// Объект, осуществляющий сборку модуля `CardList` для различных пользовательских сценариев
protocol ICardListAssembly {
    /// Создает экран со списком карт, обернутый в `UINavigationController`
    ///
    /// Используется для отображения списка карт в сценарии управления картами, доступного при открытии из родительского приложения
    /// - Parameter customerKey: Идентификатор покупателя в системе Продавца
    /// - Returns: `UINavigationController`
    func cardsPresentingNavigationController(customerKey: String) -> UINavigationController

    // TODO: MIC-8030 Добавить точку входа для оплаты по сохраненной карте
}
