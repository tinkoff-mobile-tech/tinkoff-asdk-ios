//
//  IEmailViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

protocol IEmailViewInput: AnyObject {
    func setTextFieldHeaderError()
    func setTextFieldHeaderNormal()

    func setTextField(text: String)

    func hideKeyboard()
}
