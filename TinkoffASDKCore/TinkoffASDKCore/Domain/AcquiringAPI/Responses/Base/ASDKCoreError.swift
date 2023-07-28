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
            return """
             Receipt object MUST have 'phone' OR 'email' non-empty field.
             [example-phone: '+79991459557'] or [example-email: some@email.com]
            """
        case .invalidEmail:
            return "Email is invalid. The correct format is - some@email.com"
        }
    }
}
