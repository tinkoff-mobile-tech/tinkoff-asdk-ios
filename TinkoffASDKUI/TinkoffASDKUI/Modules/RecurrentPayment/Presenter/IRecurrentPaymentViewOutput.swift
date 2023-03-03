//
//  IRecurrentPaymentViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

protocol IRecurrentPaymentViewOutput {
    func viewDidLoad()
    func viewWasClosed()
    func numberOfRows() -> Int
    func cellType(at indexPath: IndexPath) -> RecurrentPaymentCellType
    func commonSheetViewDidTapPrimaryButton()
}
