//
//  EmailViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class EmailViewInputMock: IEmailViewInput {

    // MARK: - setTextFieldHeaderError

    var setTextFieldHeaderErrorCallsCount = 0

    func setTextFieldHeaderError() {
        setTextFieldHeaderErrorCallsCount += 1
    }

    // MARK: - setTextFieldHeaderNormal

    var setTextFieldHeaderNormalCallsCount = 0

    func setTextFieldHeaderNormal() {
        setTextFieldHeaderNormalCallsCount += 1
    }

    // MARK: - setTextField

    typealias SetTextFieldArguments = (text: String, animated: Bool)

    var setTextFieldCallsCount = 0
    var setTextFieldReceivedArguments: SetTextFieldArguments?
    var setTextFieldReceivedInvocations: [SetTextFieldArguments] = []

    func setTextField(text: String, animated: Bool) {
        setTextFieldCallsCount += 1
        let arguments = (text, animated)
        setTextFieldReceivedArguments = arguments
        setTextFieldReceivedInvocations.append(arguments)
    }

    // MARK: - hideKeyboard

    var hideKeyboardCallsCount = 0

    func hideKeyboard() {
        hideKeyboardCallsCount += 1
    }
}

// MARK: - Public methods

extension EmailViewInputMock {
    func fullReset() {
        setTextFieldHeaderErrorCallsCount = 0
        setTextFieldHeaderNormalCallsCount = 0

        setTextFieldCallsCount = 0
        setTextFieldReceivedArguments = nil
        setTextFieldReceivedInvocations = []

        hideKeyboardCallsCount = 0
    }
}
