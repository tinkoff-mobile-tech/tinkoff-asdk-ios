//
//  PayType.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Тип проведения платежа - двухстадийная или одностадийная оплата.
public enum PayType: String {
    /// одностадийная оплата
    case oneStage = "O"
    /// двухстадийная оплата
    case twoStage = "T"

    public init(rawValue: String) {
        switch rawValue {
        case "O": self = .oneStage
        case "T": self = .twoStage
        default: self = .twoStage
        }
    }
}
