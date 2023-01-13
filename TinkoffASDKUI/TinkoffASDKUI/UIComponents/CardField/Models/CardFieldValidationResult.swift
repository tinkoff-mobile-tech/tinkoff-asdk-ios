//
//  CardFieldValidationResult.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.01.2023.
//

import Foundation

struct CardFieldValidationResult {
    var cardNumberIsValid = false
    var expirationIsValid = false
    var cvcIsValid = false

    var isValid: Bool { cardNumberIsValid && expirationIsValid && cvcIsValid }
}
