//
//  PaymentStatusUpdateServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

@testable import TinkoffASDKUI

final class PaymentStatusUpdateServiceMock: IPaymentStatusUpdateService {
    var delegate: IPaymentStatusUpdateServiceDelegate?

    // MARK: - startUpdateStatusIfNeeded

    typealias StartUpdateStatusIfNeededArguments = FullPaymentData

    var startUpdateStatusIfNeededCallsCount = 0
    var startUpdateStatusIfNeededReceivedArguments: StartUpdateStatusIfNeededArguments?
    var startUpdateStatusIfNeededReceivedInvocations: [StartUpdateStatusIfNeededArguments?] = []

    func startUpdateStatusIfNeeded(data: FullPaymentData) {
        startUpdateStatusIfNeededCallsCount += 1
        let arguments = data
        startUpdateStatusIfNeededReceivedArguments = arguments
        startUpdateStatusIfNeededReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension PaymentStatusUpdateServiceMock {
    func fullReset() {
        startUpdateStatusIfNeededCallsCount = 0
        startUpdateStatusIfNeededReceivedArguments = nil
        startUpdateStatusIfNeededReceivedInvocations = []
    }
}
