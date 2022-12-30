//
//  Bank.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 16.11.2022.
//

import Foundation

enum Bank: CaseIterable, Equatable {
    case sber
    case tinkoff
    case vtb
    case gazprom
    case raiffaisen
    case alpha
    case other

    var bins: [String] {
        switch self {
        case .sber:
            return Self.Bin.sber
        case .tinkoff:
            return Self.Bin.tinkoff
        case .vtb:
            return Self.Bin.vtb
        case .gazprom:
            return Self.Bin.gazprom
        case .raiffaisen:
            return Self.Bin.raiffaisen
        case .alpha:
            return Self.Bin.alpha
        case .other:
            return [String]()
        }
    }

    var icon: DynamicIconCardView.Icon.Bank {
        switch self {
        case .sber:
            return .sber
        case .tinkoff:
            return .tinkoff
        case .vtb:
            return .vtb
        case .gazprom:
            return .gazprom
        case .raiffaisen:
            return .raiffaisen
        case .alpha:
            return .alpha
        case .other:
            return .other
        }
    }

    var naming: String {
        switch self {
        case .sber:
            return Loc.Acquiring.Common.sberCardTitle
        case .tinkoff:
            return Loc.Acquiring.Common.tcsCardTitle
        case .vtb:
            return Loc.Acquiring.Common.vtbCardTitle
        case .gazprom:
            return Loc.Acquiring.Common.gazpromCardTitle
        case .raiffaisen:
            return Loc.Acquiring.Common.raiffeisenCardTitle
        case .alpha:
            return Loc.Acquiring.Common.alfaCardTitle
        case .other:
            return ""
        }
    }
}
