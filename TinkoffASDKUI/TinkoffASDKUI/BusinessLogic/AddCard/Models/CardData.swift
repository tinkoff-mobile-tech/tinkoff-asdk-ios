//
//  CardData.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

/// Даннные карты
public struct CardData: Equatable {
    /// Номер карты
    public let number: String
    /// Срок годности карты в формате `MM/YY`
    public let validThru: String
    /// Трехзначный cvc-код
    public let cvc: String

    /// Параметры карты
    /// - Parameters:
    ///   - pan: Номер карты
    ///   - validThru: Срок годности карты в формате `MM/YY`
    ///   - cvc: Трехзначный cvc-код
    public init(number: String, validThru: String, cvc: String) {
        self.number = number
        self.validThru = validThru
        self.cvc = cvc
    }
}
