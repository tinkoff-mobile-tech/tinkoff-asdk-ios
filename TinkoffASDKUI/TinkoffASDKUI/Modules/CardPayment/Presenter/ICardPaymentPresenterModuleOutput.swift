//
//  ICardPaymentPresenterModuleOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 08.02.2023.
//

protocol ICardPaymentPresenterModuleOutput: AnyObject {
    func cardPaymentPayButtonDidPressed(cardData: CardData, email: String?)
}
