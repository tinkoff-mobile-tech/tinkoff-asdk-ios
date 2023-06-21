//
//  AddCardResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Результат привязки карты
public enum AddCardResult: Equatable {
    /// Привязка карты произошла успешно.
    /// В этом случае возвращается модель с подробной информацией о карте
    case succeded(PaymentCard)
    /// В процессе привязки карты произошла ошибка
    case failed(Error)
    /// Пользователь отменил привязку новой карты
    case cancelled
}

public extension AddCardResult {

    static func == (lhs: AddCardResult, rhs: AddCardResult) -> Bool {
        switch (lhs, rhs) {

        case let (.succeded(lhsCard), .succeded(rhsCard)): return lhsCard == rhsCard
        case let (.failed(lhsErr), .failed(rhsErr)): return lhsErr as NSError === rhsErr as NSError
        case (.cancelled, .cancelled): return true

        default: return false
        }
    }
}
