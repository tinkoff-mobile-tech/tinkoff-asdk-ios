//
//  ICardPaymentViewControllerInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

protocol ICardPaymentViewControllerInput: AnyObject {
    func forceValidateCardField()

    func setPayButton(title: String)
    func setPayButton(isEnabled: Bool)
    func startLoadingPayButton()
    func stopLoadingPayButton()

    func setEmailHeader(isError: Bool)
    func setEmailTextField(text: String)

    func hideKeyboard()

    func reloadTableView()
    func insert(row: Int)
    func delete(row: Int)
}
