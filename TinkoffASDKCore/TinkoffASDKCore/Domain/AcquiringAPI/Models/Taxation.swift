//
//  Taxation.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Система налогообложения.
public enum Taxation: String {
    /// Общая
    case osn
    /// Упрощенная (доходы)
    case usnIncome = "usn_income"
    /// Упрощенная (доходы минус расходы)
    case usnIncomeOutcome = "usn_income_outcome"
    /// Единый налог на вмененный доход
    case envd
    /// Единый сельскохозяйственный налог
    case esn
    /// Патентная
    case patent

    public init(rawValue: String) {
        switch rawValue {
        case "osn": self = .osn
        case "usn_income": self = .usnIncome
        case "usn_income_outcome": self = .usnIncomeOutcome
        case "envd": self = .envd
        case "esn": self = .esn
        case "patent": self = .patent
        default: self = .osn
        }
    }
}
