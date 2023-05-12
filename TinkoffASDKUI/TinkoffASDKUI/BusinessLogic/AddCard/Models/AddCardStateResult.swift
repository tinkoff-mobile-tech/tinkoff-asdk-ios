//
//  AddCardStateResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Результат привязки карты
public enum AddCardStateResult {
    /// Привязка произошла успешно.
    /// В этом случае возвращается ответ от сервера `GetAddCardStatePayload`
    /// с информацией о статусе карты и параметрами `cardId`, `rebillId`
    case succeded(GetAddCardStatePayload)
    /// В процессе привязки карты произошла ошибка
    case failed(Error)
    /// Пользователь отменил привязку новой карты
    case cancelled
}
