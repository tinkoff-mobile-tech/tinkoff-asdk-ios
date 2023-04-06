//
//  ICardFieldOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldOutput: AnyObject {
    func scanButtonPressed()
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
}
