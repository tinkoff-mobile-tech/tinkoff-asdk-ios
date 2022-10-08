//
//  PaymentCardCheckType.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public enum PaymentCardCheckType: String {
    case no = "NO"
    case check3DS = "3DS"
    case hold = "HOLD"
    case hold3DS = "3DSHOLD"

    public init(rawValue: String) {
        switch rawValue {
        case "3DS": self = .check3DS
        case "HOLD": self = .hold
        case "3DSHOLD": self = .hold3DS
        default: self = .no
        }
    }
}
