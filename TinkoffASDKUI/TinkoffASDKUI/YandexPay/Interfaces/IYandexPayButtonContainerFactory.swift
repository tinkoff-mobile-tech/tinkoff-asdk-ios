//
//  IYandexPayButtonContainerFactory.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation

/// Фабрика для создания UI-контейнера с кнопкой `YandexPay`
///
/// Ссылку на объект фабрики можно сохранить и переиспользовать в различных сценариях приложения
public protocol IYandexPayButtonContainerFactory: AnyObject {
    /// Создает UI-контейнера с кнопкой `YandexPay` на основе переданной конфигурации
    /// - Parameters:
    ///   - configuration: Конфигурация для кнопки
    ///   - delegate: Делегат кнопки, который будет запрашивать данные для формирования платежа и уведомлять о конечном статусе платежа.
    ///   Удерживается слабой ссылкой
    /// - Returns: UI-контейнер с кнопкой `YandexPay`
    func createButtonContainer(
        with configuration: YandexPayButtonContainerConfiguration,
        delegate: IYandexPayButtonContainerDelegate
    ) -> IYandexPayButtonContainer
}
