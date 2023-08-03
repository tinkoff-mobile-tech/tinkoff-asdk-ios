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
    case invalidFinishAuthorizeData
}

extension ASDKCoreError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .missingReceiptFields:
            return Loc.ASDKCoreError.missingReceiptFields
        case .invalidEmail:
            return Loc.ASDKCoreError.invalidEmail
        case .invalidFinishAuthorizeData:
            return """
             Максимальная длина для каждого передаваемого параметра:
             Ключ - 20 знаков. Значение - 100 знаков. Максимальное количество пар ключ:значение не может превышать 20.
            """
        }
    }
}
