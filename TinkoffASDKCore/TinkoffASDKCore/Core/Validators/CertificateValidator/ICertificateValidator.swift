//
//  ICertificateValidator.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.03.2023.
//

import Security

public protocol ICertificateValidator {
    func isValid(serverTrust: SecTrust) -> Bool
}
