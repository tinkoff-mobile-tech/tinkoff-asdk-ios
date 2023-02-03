//
//  ICardFieldViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldViewInput: AnyObject {
    func updateDynamicCardView(with model: DynamicIconCardView.Model)

    func setHeaderErrorFor(textFieldType: CardFieldType)
    func setHeaderNormalFor(textFieldType: CardFieldType)

    func activate(textFieldType: CardFieldType)
    func deactivate()
}
