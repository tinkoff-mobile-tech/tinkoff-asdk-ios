//
//  ICardFieldOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldOutput: AnyObject {
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
}
