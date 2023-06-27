//
//  PaymentCardStatus.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public enum PaymentCardStatus: String, Decodable, Equatable {
    case active = "A"
    case inactive = "I"
    case deleted = "D"
    case unknown = "UNKNOWN"

    public init(rawValue: String) {
        switch rawValue {
        case "A": self = .active
        case "I": self = .inactive
        case "D": self = .deleted
        default: self = .unknown
        }
    }
}
