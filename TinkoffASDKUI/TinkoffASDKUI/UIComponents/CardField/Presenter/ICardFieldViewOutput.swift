//
//  ICardFieldViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldViewOutput: ICardFieldInput {
    var view: ICardFieldViewInput? { get set }

    func scanButtonPressed()

    func didFillField(type: CardFieldType, text: String, filled: Bool)
    func didBeginEditing(fieldType: CardFieldType)
    func didEndEditing(fieldType: CardFieldType)
}
