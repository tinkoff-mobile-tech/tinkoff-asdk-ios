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

    func emailTextFieldDidBeginEditing()
    func emailTextFieldDidChangeText(to text: String)
    func emailTextFieldDidEndEditing()

    func emailTextFieldDidPressReturn()

    func numberOfRows() -> Int
    func cellType(for row: Int) -> CardPaymentCellType
    func switchViewPresenter() -> SwitchViewPresenter
}
