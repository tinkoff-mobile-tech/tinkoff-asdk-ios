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

    var underlyingCurrentEmail = ""

    var isEmailValidGetterCount = 0
    var isEmailValidSetterCount = 0

    var isEmailValid: Bool {
        get {
            isEmailValidGetterCount += 1
            return underlyingIsEmailValid
        }
        set(value) {
            isEmailValidSetterCount += 1
            underlyingIsEmailValid = value
        }
    }

    var underlyingIsEmailValid = false

    // MARK: - textFieldDidBeginEditing

    var textFieldDidBeginEditingCallsCount = 0

    func textFieldDidBeginEditing() {
        textFieldDidBeginEditingCallsCount += 1
    }

    // MARK: - textFieldDidChangeText

    typealias TextFieldDidChangeTextArguments = String

    var textFieldDidChangeTextCallsCount = 0
    var textFieldDidChangeTextReceivedArguments: TextFieldDidChangeTextArguments?
    var textFieldDidChangeTextReceivedInvocations: [TextFieldDidChangeTextArguments?] = []

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

// MARK: - Resets

extension EmailViewOutputMock {
    func fullReset() {
        textFieldDidBeginEditingCallsCount = 0

        textFieldDidChangeTextCallsCount = 0
        textFieldDidChangeTextReceivedArguments = nil
        textFieldDidChangeTextReceivedInvocations = []

        textFieldDidEndEditingCallsCount = 0

        textFieldDidPressReturnCallsCount = 0
    }
}
