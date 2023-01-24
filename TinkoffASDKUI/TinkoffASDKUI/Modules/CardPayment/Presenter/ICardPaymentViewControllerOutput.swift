//
//  ICardPaymentViewControllerOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

protocol ICardPaymentViewControllerOutput {
    func viewDidLoad()

    func closeButtonPressed()
    func payButtonPressed()

    func cardFieldDidChangeState(isValid: Bool)

    func viewPresenter(for row: Int) -> SwitchViewPresenter
}
