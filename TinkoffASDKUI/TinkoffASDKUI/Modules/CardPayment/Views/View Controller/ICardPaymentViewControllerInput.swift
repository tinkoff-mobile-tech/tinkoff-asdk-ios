//
//  ICardPaymentViewControllerInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

protocol ICardPaymentViewControllerInput: AnyObject {
    func startIgnoringInteractionEvents()
    func stopIgnoringInteractionEvents()

    func hideKeyboard()

    func reloadTableView()
    func insert(row: Int)
    func delete(row: Int)
}
