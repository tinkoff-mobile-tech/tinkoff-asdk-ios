//
//  AgentSign.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Признак агента
public enum AgentSign: String, Equatable {
    /// Банковский платежный агент
    case bankPayingAgent = "bank_paying_agent"
    /// Банковский платежный субагент
    case bankPayingSubagent = "bank_paying_subagent"
    /// Платежный агент
    case payingAgent = "paying_agent"
    /// Платежный субагент
    case payingSubagent = "paying_subagent"
    /// Поверенный
    case attorney
    /// Комиссионер
    case commissionAgent = "commission_agent"
    /// Другой тип агента
    case another

    public init(rawValue: String) {
        switch rawValue {
        case "bank_paying_agent": self = .bankPayingAgent
        case "bank_paying_subagent": self = .bankPayingSubagent
        case "paying_agent": self = .payingAgent
        case "paying_subagent": self = .payingSubagent
        case "attorney": self = .attorney
        case "commission_agent": self = .commissionAgent
        default: self = .another
        }
    }
}
