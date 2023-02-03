//
//  ICardFieldInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldInput: AnyObject {
    var cardNumber: String { get }
    var expiration: String { get }
    var cvc: String { get }

    var validationResult: CardFieldValidationResult { get }

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult
}
