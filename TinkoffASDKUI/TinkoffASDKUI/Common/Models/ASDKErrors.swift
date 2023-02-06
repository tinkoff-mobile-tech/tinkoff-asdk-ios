//
//  ASDKErrors.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 06.02.2023.
//

import Foundation

public enum ASDKErrors {
    case timeout(nestedError: Error? = nil)
    case rejected

    var error: Error {
        switch self {
        case let .timeout(err):
            let userInfo: [String: Any]? = {
                if let err = err {
                    return ["nestedError": err]
                } else {
                    return nil
                }
            }()
            return NSError(domain: "time or retries count is over", code: 123_001, userInfo: userInfo)
        case .rejected: return NSError(domain: "payment failed", code: 123_002)
        }
    }
}
