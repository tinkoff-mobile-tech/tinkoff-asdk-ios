//
//  IRecurrentPaymentViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

protocol IRecurrentPaymentViewInput: AnyObject {
    func showCommonSheet(state: CommonSheetState)
    func hideCommonSheet()

    func hideKeyboard()

    func reloadData()
    func closeView()
}
