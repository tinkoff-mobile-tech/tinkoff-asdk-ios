//
//  PaymentMethod.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Тип оплаты
public enum PaymentMethod: String {
    /// Предоплата 100%
    /// Полная предварительная оплата до момента передачи предмета расчета
    case fullPrepayment = "full_prepayment"
    /// Предоплата
    /// Частичная предварительная оплата до момента передачи предмета расчета
    case prepayment
    /// Аванс
    case advance
    /// Полный расчет
    /// Полная оплата, в том числе с учетом аванса (предварительной оплаты) в момент передачи
    case fullPayment = "full_payment"
    /// Частичный расчет и кредит
    /// Частичная оплата предмета расчета в момент его передачи с последующей оплатой в кредит
    case partialPayment = "partial_payment"
    /// Передача в кредит
    /// Передача предмета расчета без его оплаты в момент его передачи с последующей оплатой в кредит
    case credit
    /// Оплата кредита
    /// Оплата предмета расчета после его передачи с оплатой в кредит
    case creditPayment = "credit_payment"

    public init(rawValue: String) {
        switch rawValue {
        case "full_prepayment": self = .fullPrepayment
        case "prepayment": self = .prepayment
        case "advance": self = .advance
        case "full_payment": self = .fullPayment
        case "partial_payment": self = .partialPayment
        case "credit": self = .credit
        case "credit_payment": self = .creditPayment
        default: self = .fullPrepayment
        }
    }
}
