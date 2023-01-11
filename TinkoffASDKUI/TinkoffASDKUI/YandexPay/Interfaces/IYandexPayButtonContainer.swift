//
//  IYandexPayButtonContainer.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import UIKit

/// UI-контейнер для кнопки `YandexPay`
public protocol IYandexPayButtonContainer: UIView {
    /// Установленная тема
    var theme: YandexPayButtonContainerTheme { get }

    /// Переключает состояние индикатора загрузки на кнопке
    func setLoaderVisible(_ visible: Bool, animated: Bool)

    /// Перезагружает данные персонализации на кнопке
    func reloadPersonalizationData(completion: @escaping (Error?) -> Void)

    /// Устанавливает новую тему для кнопки
    func setTheme(_ theme: YandexPayButtonContainerTheme, animated: Bool)
}
