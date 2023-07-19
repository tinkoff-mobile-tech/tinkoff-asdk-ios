//
//  SBPPaymentServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPPaymentServiceMock: ISBPPaymentService {

    // MARK: - loadPaymentQr

    typealias LoadPaymentQrArguments = SBPPaymentServiceCompletion

    var loadPaymentQrCallsCount = 0
    var loadPaymentQrReceivedArguments: LoadPaymentQrArguments?
    var loadPaymentQrReceivedInvocations: [LoadPaymentQrArguments?] = []
    var loadPaymentQrCompletionClosureInput: Result<GetQRPayload, Error>?

    func loadPaymentQr(completion: @escaping SBPPaymentServiceCompletion) {
        loadPaymentQrCallsCount += 1
        let arguments = completion
        loadPaymentQrReceivedArguments = arguments
        loadPaymentQrReceivedInvocations.append(arguments)
        if let loadPaymentQrCompletionClosureInput = loadPaymentQrCompletionClosureInput {
            completion(loadPaymentQrCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension SBPPaymentServiceMock {
    func fullReset() {
        loadPaymentQrCallsCount = 0
        loadPaymentQrReceivedArguments = nil
        loadPaymentQrReceivedInvocations = []
        loadPaymentQrCompletionClosureInput = nil
    }
}
