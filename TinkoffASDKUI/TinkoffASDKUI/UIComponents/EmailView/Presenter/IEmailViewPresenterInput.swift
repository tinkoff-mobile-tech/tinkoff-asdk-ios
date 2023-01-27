//
//  IEmailViewPresenterInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

protocol IEmailViewPresenterInput {
    var customerEmail: String { get }
    var currentEmail: String { get }
    var isEmailValid: Bool { get }
}
