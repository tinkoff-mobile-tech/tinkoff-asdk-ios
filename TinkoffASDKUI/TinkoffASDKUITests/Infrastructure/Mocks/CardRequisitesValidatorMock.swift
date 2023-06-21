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

    // MARK: - validate

    var validateInputPANCallsCount = 0
    var validateInputPANReceivedArguments: String?
    var validateInputPANReceivedInvocations: [String?] = []
    var validateInputPANReturnValue: Bool = false

    func validate(inputPAN: String?) -> Bool {
        validateInputPANCallsCount += 1
        let arguments = inputPAN
        validateInputPANReceivedArguments = arguments
        validateInputPANReceivedInvocations.append(arguments)
        return validateInputPANReturnValue
    }

    // MARK: - validate

    typealias ValidateArguments = (validThruYear: Int, month: Int)

    var validateValidThruYearCallsCount = 0
    var validateValidThruYearReceivedArguments: ValidateArguments?
    var validateValidThruYearReceivedInvocations: [ValidateArguments] = []
    var validateValidThruYearReturnValue: Bool = false

    func validate(validThruYear: Int, month: Int) -> Bool {
        validateValidThruYearCallsCount += 1
        let arguments = (validThruYear, month)
        validateValidThruYearReceivedArguments = arguments
        validateValidThruYearReceivedInvocations.append(arguments)
        return validateValidThruYearReturnValue
    }

    var validateInputValidThruYearCallsCount = 0
    var validateInputValidThruYearReceivedArguments: String?
    var validateInputValidThruYearReceivedInvocations: [String?] = []
    var validateInputValidThruYearReturnValue: Bool = false

    func validate(inputValidThru: String?) -> Bool {
        validateInputValidThruYearCallsCount += 1
        let arguments = inputValidThru
        validateInputValidThruYearReceivedArguments = arguments
        validateInputValidThruYearReceivedInvocations.append(arguments)
        return validateInputValidThruYearReturnValue
    }

    // MARK: - validate

    var validateInputCVCCallsCount = 0
    var validateInputCVCReceivedArguments: String?
    var validateInputCVCReceivedInvocations: [String?] = []
    var validateInputCVCReturnValue: Bool = false

    func validate(inputCVC: String?) -> Bool {
        validateInputCVCCallsCount += 1
        let arguments = inputCVC
        validateInputCVCReceivedArguments = arguments
        validateInputCVCReceivedInvocations.append(arguments)
        return validateInputCVCReturnValue
    }
}

// MARK: - Public methods

extension CardRequisitesValidatorMock {
    func fullReset() {
        validateInputPANCallsCount = 0
        validateInputPANReceivedArguments = nil
        validateInputPANReceivedInvocations = []
        validateInputPANReturnValue = false

        validateValidThruYearCallsCount = 0
        validateValidThruYearReceivedArguments = nil
        validateValidThruYearReceivedInvocations = []
        validateValidThruYearReturnValue = false

        validateInputValidThruYearCallsCount = 0
        validateInputValidThruYearReceivedArguments = nil
        validateInputValidThruYearReceivedInvocations = []
        validateInputValidThruYearReturnValue = false

        validateInputCVCCallsCount = 0
        validateInputCVCReceivedArguments = nil
        validateInputCVCReceivedInvocations = []
        validateInputCVCReturnValue = false
    }
}
