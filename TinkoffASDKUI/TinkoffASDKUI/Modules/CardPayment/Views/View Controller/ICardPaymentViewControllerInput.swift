//
//  ICardPaymentViewControllerInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

protocol ICardPaymentViewControllerInput: AnyObject {
    func startIgnoringInteractionEvents()
    func stopIgnoringInteractionEvents()

    func showActivityIndicator(with style: ActivityIndicatorView.Style)
    func hideActivityIndicator()

    func hideKeyboard()

    func reloadTableView()
    func insert(row: Int)
    func delete(row: Int)
}
