//
//  MaskedTextFieldDelegateListenerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 01.06.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class MaskedTextFieldDelegateListenerMock: NSObject, MaskedTextFieldDelegateListener {

    // MARK: - textField

    typealias TextFieldArguments = (textField: UITextField, complete: Bool, value: String)

    var textFieldCallsCount = 0
    var textFieldReceivedArguments: TextFieldArguments?
    var textFieldReceivedInvocations: [TextFieldArguments?] = []

    @objc
    func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
        textFieldCallsCount += 1
        let arguments = (textField, complete, value)
        textFieldReceivedArguments = arguments
        textFieldReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension MaskedTextFieldDelegateListenerMock {
    func fullReset() {
        textFieldCallsCount = 0
        textFieldReceivedArguments = nil
        textFieldReceivedInvocations = []
    }
}
