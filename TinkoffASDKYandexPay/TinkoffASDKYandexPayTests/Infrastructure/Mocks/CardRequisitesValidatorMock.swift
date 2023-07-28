//
//  CardRequisitesValidatorMock.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class CardRequisitesValidatorMock: ICardRequisitesValidator {

    // MARK: - validateInputPAN

    typealias ValidateInputPANArguments = String

    var validateInputPANCallsCount = 0
    var validateInputPANReceivedArguments: ValidateInputPANArguments?
    var validateInputPANReceivedInvocations: [ValidateInputPANArguments?] = []
    var validateInputPANReturnValue = false

    func validate(inputPAN: String?) -> Bool {
        validateInputPANCallsCount += 1
        let arguments = inputPAN
        validateInputPANReceivedArguments = arguments
        validateInputPANReceivedInvocations.append(arguments)
        return validateInputPANReturnValue
    }

    // MARK: - validateValidThruYearMonth

    typealias ValidateValidThruYearMonthArguments = (validThruYear: Int, month: Int)

    var validateValidThruYearMonthCallsCount = 0
    var validateValidThruYearMonthReceivedArguments: ValidateValidThruYearMonthArguments?
    var validateValidThruYearMonthReceivedInvocations: [ValidateValidThruYearMonthArguments?] = []
    var validateValidThruYearMonthReturnValue = false

    func validate(validThruYear: Int, month: Int) -> Bool {
        validateValidThruYearMonthCallsCount += 1
        let arguments = (validThruYear, month)
        validateValidThruYearMonthReceivedArguments = arguments
        validateValidThruYearMonthReceivedInvocations.append(arguments)
        return validateValidThruYearMonthReturnValue
    }

    // MARK: - validateInputValidThru

    typealias ValidateInputValidThruArguments = String

    var validateInputValidThruCallsCount = 0
    var validateInputValidThruReceivedArguments: ValidateInputValidThruArguments?
    var validateInputValidThruReceivedInvocations: [ValidateInputValidThruArguments?] = []
    var validateInputValidThruReturnValue = false

    func validate(inputValidThru: String?) -> Bool {
        validateInputValidThruCallsCount += 1
        let arguments = inputValidThru
        validateInputValidThruReceivedArguments = arguments
        validateInputValidThruReceivedInvocations.append(arguments)
        return validateInputValidThruReturnValue
    }

    // MARK: - validateInputCVC

    typealias ValidateInputCVCArguments = String

    var validateInputCVCCallsCount = 0
    var validateInputCVCReceivedArguments: ValidateInputCVCArguments?
    var validateInputCVCReceivedInvocations: [ValidateInputCVCArguments?] = []
    var validateInputCVCReturnValue = false

    func validate(inputCVC: String?) -> Bool {
        validateInputCVCCallsCount += 1
        let arguments = inputCVC
        validateInputCVCReceivedArguments = arguments
        validateInputCVCReceivedInvocations.append(arguments)
        return validateInputCVCReturnValue
    }
}

// MARK: - Resets

extension CardRequisitesValidatorMock {
    func fullReset() {
        validateInputPANCallsCount = 0
        validateInputPANReceivedArguments = nil
        validateInputPANReceivedInvocations = []

        validateValidThruYearMonthCallsCount = 0
        validateValidThruYearMonthReceivedArguments = nil
        validateValidThruYearMonthReceivedInvocations = []

        validateInputValidThruCallsCount = 0
        validateInputValidThruReceivedArguments = nil
        validateInputValidThruReceivedInvocations = []

        validateInputCVCCallsCount = 0
        validateInputCVCReceivedArguments = nil
        validateInputCVCReceivedInvocations = []
    }
}
