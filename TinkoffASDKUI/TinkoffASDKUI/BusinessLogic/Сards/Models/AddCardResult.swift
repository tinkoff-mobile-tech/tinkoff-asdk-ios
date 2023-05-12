//
//  AddCardResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Результат привязки карты
public enum AddCardResult {
    /// Привязка карты произошла успешно.
    /// В этом случае возвращается модель с подробной информацией о карте
    case succeded(PaymentCard)
    /// В процессе привязки карты произошла ошибка
    case failed(Error)
    /// Пользователь отменил привязку новой карты
    case cancelled
}
