//
//  ICardFieldViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

import UIKit

protocol ICardFieldViewInput: AnyObject {
    func updateDynamicCardView(with model: DynamicIconCardView.Model)
    func updateCardNumberField(with maskFormat: String) -> Bool

    func activateScanButton()
    func setCardNumberTextField(rightViewMode: UITextField.ViewMode)

    func set(textFieldType: CardFieldType, text: String?)
    func setHeaderErrorFor(textFieldType: CardFieldType)
    func setHeaderNormalFor(textFieldType: CardFieldType)

    func activate(textFieldType: CardFieldType)
    func deactivate()
}
