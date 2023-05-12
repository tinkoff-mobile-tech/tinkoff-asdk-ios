//
//  ICardFieldInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldInput: AnyObject {
    var cardData: CardData { get }

    var cardNumber: String { get }
    var expiration: String { get }
    var cvc: String { get }

    func set(textFieldType: CardFieldType, text: String?)
    func activate(textFieldType: CardFieldType)

    var validationResult: CardFieldValidationResult { get }

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult
}
