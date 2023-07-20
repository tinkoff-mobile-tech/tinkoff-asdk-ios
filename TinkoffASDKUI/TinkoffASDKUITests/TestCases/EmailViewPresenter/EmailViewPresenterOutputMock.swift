//
//  EmailViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class EmailViewPresenterOutputMock: IEmailViewPresenterOutput {

    // MARK: - emailTextFieldDidBeginEditing

    typealias EmailTextFieldDidBeginEditingArguments = EmailViewPresenter

    var emailTextFieldDidBeginEditingCallsCount = 0
    var emailTextFieldDidBeginEditingReceivedArguments: EmailTextFieldDidBeginEditingArguments?
    var emailTextFieldDidBeginEditingReceivedInvocations: [EmailTextFieldDidBeginEditingArguments?] = []

    func emailTextFieldDidBeginEditing(_ presenter: EmailViewPresenter) {
        emailTextFieldDidBeginEditingCallsCount += 1
        let arguments = presenter
        emailTextFieldDidBeginEditingReceivedArguments = arguments
        emailTextFieldDidBeginEditingReceivedInvocations.append(arguments)
    }

    // MARK: - emailTextField

    typealias EmailTextFieldArguments = (presenter: EmailViewPresenter, email: String, isValid: Bool)

    var emailTextFieldCallsCount = 0
    var emailTextFieldReceivedArguments: EmailTextFieldArguments?
    var emailTextFieldReceivedInvocations: [EmailTextFieldArguments?] = []

    func emailTextField(_ presenter: EmailViewPresenter, didChangeEmail email: String, isValid: Bool) {
        emailTextFieldCallsCount += 1
        let arguments = (presenter, email, isValid)
        emailTextFieldReceivedArguments = arguments
        emailTextFieldReceivedInvocations.append(arguments)
    }

    // MARK: - emailTextFieldDidEndEditing

    typealias EmailTextFieldDidEndEditingArguments = EmailViewPresenter

    var emailTextFieldDidEndEditingCallsCount = 0
    var emailTextFieldDidEndEditingReceivedArguments: EmailTextFieldDidEndEditingArguments?
    var emailTextFieldDidEndEditingReceivedInvocations: [EmailTextFieldDidEndEditingArguments?] = []

    func emailTextFieldDidEndEditing(_ presenter: EmailViewPresenter) {
        emailTextFieldDidEndEditingCallsCount += 1
        let arguments = presenter
        emailTextFieldDidEndEditingReceivedArguments = arguments
        emailTextFieldDidEndEditingReceivedInvocations.append(arguments)
    }

    // MARK: - emailTextFieldDidPressReturn

    typealias EmailTextFieldDidPressReturnArguments = EmailViewPresenter

    var emailTextFieldDidPressReturnCallsCount = 0
    var emailTextFieldDidPressReturnReceivedArguments: EmailTextFieldDidPressReturnArguments?
    var emailTextFieldDidPressReturnReceivedInvocations: [EmailTextFieldDidPressReturnArguments?] = []

    func emailTextFieldDidPressReturn(_ presenter: EmailViewPresenter) {
        emailTextFieldDidPressReturnCallsCount += 1
        let arguments = presenter
        emailTextFieldDidPressReturnReceivedArguments = arguments
        emailTextFieldDidPressReturnReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension EmailViewPresenterOutputMock {
    func fullReset() {
        emailTextFieldDidBeginEditingCallsCount = 0
        emailTextFieldDidBeginEditingReceivedArguments = nil
        emailTextFieldDidBeginEditingReceivedInvocations = []

        emailTextFieldCallsCount = 0
        emailTextFieldReceivedArguments = nil
        emailTextFieldReceivedInvocations = []

        emailTextFieldDidEndEditingCallsCount = 0
        emailTextFieldDidEndEditingReceivedArguments = nil
        emailTextFieldDidEndEditingReceivedInvocations = []

        emailTextFieldDidPressReturnCallsCount = 0
        emailTextFieldDidPressReturnReceivedArguments = nil
        emailTextFieldDidPressReturnReceivedInvocations = []
    }
}
