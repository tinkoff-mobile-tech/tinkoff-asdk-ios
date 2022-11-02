//
//  Tax.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Ставка налога
public enum Tax: String, Equatable {
    /// НДС по ставке 0%
    case vat0
    /// НДС чека по ставке 10%
    case vat10
    /// НДС чека по ставке 18%
    case vat18
    /// НДС чека по ставке 20%
    case vat20
    /// НДС чека по расчетной ставке 10/110
    case vat110
    /// НДС чека по расчетной ставке 18/118
    case vat118
    /// НДС чека по расчетной ставке 20/120
    case vat120
    /// Без НДС
    case none

    public init(rawValue: String) {
        switch rawValue {
        case "vat0": self = .vat0
        case "vat10": self = .vat10
        case "vat18": self = .vat18
        case "vat20": self = .vat20
        case "vat110": self = .vat110
        case "vat118": self = .vat118
        case "vat120": self = .vat20
        default: self = .none
        }
    }
}
