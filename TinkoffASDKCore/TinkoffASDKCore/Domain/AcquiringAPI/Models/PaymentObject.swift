//
//  PaymentObject.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Признак предмета расчета
public enum PaymentObject: String {
    /// Подакцизный товар
    case excise
    /// Работа
    case job
    /// Услуга
    case service
    /// Ставка азартной игры
    case gamblingBet = "gambling_bet"
    /// Выигрыш азартной игры
    case gamblingPrize = "gambling_prize"
    /// Лотерейный билет
    case lottery
    /// Выигрыш лотереи
    case lotteryPrize = "lottery_prize"
    /// Предоставление результатов интеллектуальной деятельности
    case intellectualActivity = "intellectual_activity"
    /// Платеж
    case payment
    /// Агентское вознаграждение
    case agentCommission = "agent_commission"
    /// Составной предмет расчета
    case composite
    /// Иной предмет расчета
    case another

    public init(rawValue: String) {
        switch rawValue {
        case "excise": self = .excise
        case "job": self = .job
        case "service": self = .service
        case "gambling_bet": self = .gamblingBet
        case "gambling_prize": self = .gamblingPrize
        case "lottery": self = .lottery
        case "lottery_prize": self = .lotteryPrize
        case "intellectual_activity": self = .intellectualActivity
        case "payment": self = .payment
        case "agent_commission": self = .agentCommission
        case "composite": self = .composite
        default: self = .another
        }
    }
}
