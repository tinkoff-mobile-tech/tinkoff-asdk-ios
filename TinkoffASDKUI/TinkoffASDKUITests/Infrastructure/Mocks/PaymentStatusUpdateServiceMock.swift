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

    var startUpdateStatusIfNeededCallsCount = 0
    var startUpdateStatusIfNeededReceivedArguments: FullPaymentData?
    var startUpdateStatusIfNeededReceivedInvocations: [FullPaymentData] = []

    func startUpdateStatusIfNeeded(data: FullPaymentData) {
        startUpdateStatusIfNeededCallsCount += 1
        let arguments = data
        startUpdateStatusIfNeededReceivedArguments = arguments
        startUpdateStatusIfNeededReceivedInvocations.append(arguments)
    }
}
