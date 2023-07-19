//
//  RecurrentPaymentFailiureDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 05.06.2023.
//

@testable import TinkoffASDKUI

final class RecurrentPaymentFailiureDelegateMock: IRecurrentPaymentFailiureDelegate {

    // MARK: - recurrentPaymentNeedRepeatInit

    typealias RecurrentPaymentNeedRepeatInitArguments = (additionalData: [String: String], completion: (Result<PaymentId, Error>) -> Void)

    var recurrentPaymentNeedRepeatInitCallsCount = 0
    var recurrentPaymentNeedRepeatInitReceivedArguments: RecurrentPaymentNeedRepeatInitArguments?
    var recurrentPaymentNeedRepeatInitReceivedInvocations: [RecurrentPaymentNeedRepeatInitArguments?] = []
    var recurrentPaymentNeedRepeatInitCompletionClosureInput: Result<PaymentId, Error>?

    func recurrentPaymentNeedRepeatInit(additionalData: [String: String], completion: @escaping (Result<PaymentId, Error>) -> Void) {
        recurrentPaymentNeedRepeatInitCallsCount += 1
        let arguments = (additionalData, completion)
        recurrentPaymentNeedRepeatInitReceivedArguments = arguments
        recurrentPaymentNeedRepeatInitReceivedInvocations.append(arguments)
        if let recurrentPaymentNeedRepeatInitCompletionClosureInput = recurrentPaymentNeedRepeatInitCompletionClosureInput {
            completion(recurrentPaymentNeedRepeatInitCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension RecurrentPaymentFailiureDelegateMock {
    func fullReset() {
        recurrentPaymentNeedRepeatInitCallsCount = 0
        recurrentPaymentNeedRepeatInitReceivedArguments = nil
        recurrentPaymentNeedRepeatInitReceivedInvocations = []
        recurrentPaymentNeedRepeatInitCompletionClosureInput = nil
    }
}
