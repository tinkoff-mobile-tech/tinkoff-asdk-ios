//
//  ICardFieldViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldViewOutput: ICardFieldInput {
    var view: ICardFieldViewInput? { get set }

    func didFillCardNumber(text: String, filled: Bool)
    func didFillExpiration(text: String, filled: Bool)
    func didFillCvc(text: String, filled: Bool)

    func didBeginEditing(fieldType: CardFieldType)
    func didEndEditing(fieldType: CardFieldType)
}
