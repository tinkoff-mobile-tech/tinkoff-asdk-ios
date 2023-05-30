//
//  EmailViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class EmailViewPresenterOutputMock: IEmailViewPresenterOutput {

    // MARK: - emailTextFieldDidBeginEditing

    var emailTextFieldDidBeginEditingCallsCount = 0
    var emailTextFieldDidBeginEditingReceivedArguments: EmailViewPresenter?
    var emailTextFieldDidBeginEditingReceivedInvocations: [EmailViewPresenter] = []

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
    var emailTextFieldReceivedInvocations: [EmailTextFieldArguments] = []

    func emailTextField(_ presenter: EmailViewPresenter, didChangeEmail email: String, isValid: Bool) {
        emailTextFieldCallsCount += 1
        let arguments = (presenter, email, isValid)
        emailTextFieldReceivedArguments = arguments
        emailTextFieldReceivedInvocations.append(arguments)
    }

    // MARK: - emailTextFieldDidEndEditing

    var emailTextFieldDidEndEditingCallsCount = 0
    var emailTextFieldDidEndEditingReceivedArguments: EmailViewPresenter?
    var emailTextFieldDidEndEditingReceivedInvocations: [EmailViewPresenter] = []

    func emailTextFieldDidEndEditing(_ presenter: EmailViewPresenter) {
        emailTextFieldDidEndEditingCallsCount += 1
        let arguments = presenter
        emailTextFieldDidEndEditingReceivedArguments = arguments
        emailTextFieldDidEndEditingReceivedInvocations.append(arguments)
    }

    // MARK: - emailTextFieldDidPressReturn

    var emailTextFieldDidPressReturnCallsCount = 0
    var emailTextFieldDidPressReturnReceivedArguments: EmailViewPresenter?
    var emailTextFieldDidPressReturnReceivedInvocations: [EmailViewPresenter] = []

    func emailTextFieldDidPressReturn(_ presenter: EmailViewPresenter) {
        emailTextFieldDidPressReturnCallsCount += 1
        let arguments = presenter
        emailTextFieldDidPressReturnReceivedArguments = arguments
        emailTextFieldDidPressReturnReceivedInvocations.append(arguments)
    }
}
