//
//  ASDKCoreError.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 26.07.2023.
//

import Foundation

public enum ASDKCoreError: Error {
    case missingReceiptFields
    case invalidEmail
}

extension ASDKCoreError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .missingReceiptFields:
            return Loc.ASDKCoreError.missingReceiptFields
        case .invalidEmail:
            return Loc.ASDKCoreError.invalidEmail
        }
    }
}
