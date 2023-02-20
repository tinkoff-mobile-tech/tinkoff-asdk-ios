//
//  CardOptions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

/// Параметры карты
public struct CardOptions {
    /// Номер карты
    public let pan: String
    /// Срок годности карты в формате `MM/YY`
    public let validThru: String
    /// Трехзначный cvc-код
    public let cvc: String

    /// Параметры карты
    /// - Parameters:
    ///   - pan: Номер карты
    ///   - validThru: Срок годности карты в формате `MM/YY`
    ///   - cvc: Трехзначный cvc-код
    public init(pan: String, validThru: String, cvc: String) {
        self.pan = pan
        self.validThru = validThru
        self.cvc = cvc
    }
}
