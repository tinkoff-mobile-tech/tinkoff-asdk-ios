//
//  EmailViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class EmailViewOutputMock: IEmailViewOutput {
    var view: IEmailViewInput?
    var customerEmail: String {
        get { return underlyingCustomerEmail }
        set(value) { underlyingCustomerEmail = value }
    }

    var underlyingCustomerEmail: String!
    var currentEmail: String {
        get { return underlyingCurrentEmail }
        set(value) { underlyingCurrentEmail = value }
    }

    var underlyingCurrentEmail: String = ""
    var isEmailValid: Bool {
        get { return underlyingIsEmailValid }
        set(value) { underlyingIsEmailValid = value }
    }

    var underlyingIsEmailValid: Bool = false

    // MARK: - textFieldDidBeginEditing

    var textFieldDidBeginEditingCallsCount = 0

    func textFieldDidBeginEditing() {
        textFieldDidBeginEditingCallsCount += 1
    }

    // MARK: - textFieldDidChangeText

    var textFieldDidChangeTextCallsCount = 0
    var textFieldDidChangeTextReceivedArguments: String?
    var textFieldDidChangeTextReceivedInvocations: [String] = []

    func textFieldDidChangeText(to text: String) {
        textFieldDidChangeTextCallsCount += 1
        let arguments = text
        textFieldDidChangeTextReceivedArguments = arguments
        textFieldDidChangeTextReceivedInvocations.append(arguments)
    }

    // MARK: - textFieldDidEndEditing

    var textFieldDidEndEditingCallsCount = 0

    func textFieldDidEndEditing() {
        textFieldDidEndEditingCallsCount += 1
    }

    // MARK: - textFieldDidPressReturn

    var textFieldDidPressReturnCallsCount = 0

    func textFieldDidPressReturn() {
        textFieldDidPressReturnCallsCount += 1
    }
}
