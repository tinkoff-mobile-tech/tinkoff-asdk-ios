//
//  PaymentStatusUpdateServiceDelegateMock.swift
//  Pods
//
//  Created by Ivan Glushko on 06.06.2023.
//

@testable import TinkoffASDKUI

final class PaymentStatusUpdateServiceDelegateMock: IPaymentStatusUpdateServiceDelegate {

    // MARK: - paymentFinalStatusRecieved

    typealias PaymentFinalStatusRecievedArguments = FullPaymentData

    var paymentFinalStatusRecievedCallsCount = 0
    var paymentFinalStatusRecievedReceivedArguments: PaymentFinalStatusRecievedArguments?
    var paymentFinalStatusRecievedReceivedInvocations: [PaymentFinalStatusRecievedArguments?] = []

    func paymentFinalStatusRecieved(data: FullPaymentData) {
        paymentFinalStatusRecievedCallsCount += 1
        let arguments = data
        paymentFinalStatusRecievedReceivedArguments = arguments
        paymentFinalStatusRecievedReceivedInvocations.append(arguments)
    }

    // MARK: - paymentCancelStatusRecieved

    typealias PaymentCancelStatusRecievedArguments = FullPaymentData

    var paymentCancelStatusRecievedCallsCount = 0
    var paymentCancelStatusRecievedReceivedArguments: PaymentCancelStatusRecievedArguments?
    var paymentCancelStatusRecievedReceivedInvocations: [PaymentCancelStatusRecievedArguments?] = []

    func paymentCancelStatusRecieved(data: FullPaymentData) {
        paymentCancelStatusRecievedCallsCount += 1
        let arguments = data
        paymentCancelStatusRecievedReceivedArguments = arguments
        paymentCancelStatusRecievedReceivedInvocations.append(arguments)
    }

    // MARK: - paymentFailureStatusRecieved

    typealias PaymentFailureStatusRecievedArguments = (data: FullPaymentData, error: Error)

    var paymentFailureStatusRecievedCallsCount = 0
    var paymentFailureStatusRecievedReceivedArguments: PaymentFailureStatusRecievedArguments?
    var paymentFailureStatusRecievedReceivedInvocations: [PaymentFailureStatusRecievedArguments?] = []

    func paymentFailureStatusRecieved(data: FullPaymentData, error: Error) {
        paymentFailureStatusRecievedCallsCount += 1
        let arguments = (data, error)
        paymentFailureStatusRecievedReceivedArguments = arguments
        paymentFailureStatusRecievedReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension PaymentStatusUpdateServiceDelegateMock {
    func fullReset() {
        paymentFinalStatusRecievedCallsCount = 0
        paymentFinalStatusRecievedReceivedArguments = nil
        paymentFinalStatusRecievedReceivedInvocations = []

        paymentCancelStatusRecievedCallsCount = 0
        paymentCancelStatusRecievedReceivedArguments = nil
        paymentCancelStatusRecievedReceivedInvocations = []

        paymentFailureStatusRecievedCallsCount = 0
        paymentFailureStatusRecievedReceivedArguments = nil
        paymentFailureStatusRecievedReceivedInvocations = []
    }
}
