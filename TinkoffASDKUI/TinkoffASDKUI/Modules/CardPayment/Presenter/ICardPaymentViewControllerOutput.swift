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

    func numberOfRows() -> Int
    func cellType(for row: Int) -> CardPaymentCellType
    func savedCardViewPresenter() -> SavedCardPresenter?
    func emailViewPresenter() -> EmailViewPresenter
    func switchViewPresenter() -> SwitchViewPresenter
}
