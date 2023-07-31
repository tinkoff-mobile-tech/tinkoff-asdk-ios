//
//  AcquiringPaymentsServiceMock.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringPaymentsServiceMock: IAcquiringPaymentsService {

    // MARK: - initPayment

    typealias InitPaymentArguments = (data: PaymentInitData, completion: (_ result: Result<InitPayload, Error>) -> Void)

    var initPaymentCallsCount = 0
    var initPaymentReceivedArguments: InitPaymentArguments?
    var initPaymentReceivedInvocations: [InitPaymentArguments?] = []
    var initPaymentCompletionClosureInput: Result<InitPayload, Error>?
    var initPaymentReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func initPayment(data: PaymentInitData, completion: @escaping (_ result: Result<InitPayload, Error>) -> Void) -> Cancellable {
        initPaymentCallsCount += 1
        let arguments = (data, completion)
        initPaymentReceivedArguments = arguments
        initPaymentReceivedInvocations.append(arguments)
        if let initPaymentCompletionClosureInput = initPaymentCompletionClosureInput {
            completion(initPaymentCompletionClosureInput)
        }
        return initPaymentReturnValue
    }

    // MARK: - finishAuthorize

    typealias FinishAuthorizeArguments = (data: FinishAuthorizeData, completion: (_ result: Result<FinishAuthorizePayload, Error>) -> Void)

    var finishAuthorizeCallsCount = 0
    var finishAuthorizeReceivedArguments: FinishAuthorizeArguments?
    var finishAuthorizeReceivedInvocations: [FinishAuthorizeArguments?] = []
    var finishAuthorizeCompletionClosureInput: Result<FinishAuthorizePayload, Error>?
    var finishAuthorizeReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func finishAuthorize(data: FinishAuthorizeData, completion: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void) -> Cancellable {
        finishAuthorizeCallsCount += 1
        let arguments = (data, completion)
        finishAuthorizeReceivedArguments = arguments
        finishAuthorizeReceivedInvocations.append(arguments)
        if let finishAuthorizeCompletionClosureInput = finishAuthorizeCompletionClosureInput {
            completion(finishAuthorizeCompletionClosureInput)
        }
        return finishAuthorizeReturnValue
    }

    // MARK: - charge

    typealias ChargeArguments = (data: ChargeData, completion: (_ result: Result<ChargePayload, Error>) -> Void)

    var chargeCallsCount = 0
    var chargeReceivedArguments: ChargeArguments?
    var chargeReceivedInvocations: [ChargeArguments?] = []
    var chargeCompletionClosureInput: Result<ChargePayload, Error>?
    var chargeReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func charge(data: ChargeData, completion: @escaping (_ result: Result<ChargePayload, Error>) -> Void) -> Cancellable {
        chargeCallsCount += 1
        let arguments = (data, completion)
        chargeReceivedArguments = arguments
        chargeReceivedInvocations.append(arguments)
        if let chargeCompletionClosureInput = chargeCompletionClosureInput {
            completion(chargeCompletionClosureInput)
        }
        return chargeReturnValue
    }

    // MARK: - getPaymentState

    typealias GetPaymentStateArguments = (data: GetPaymentStateData, completion: (_ result: Result<GetPaymentStatePayload, Error>) -> Void)

    var getPaymentStateCallsCount = 0
    var getPaymentStateReceivedArguments: GetPaymentStateArguments?
    var getPaymentStateReceivedInvocations: [GetPaymentStateArguments?] = []
    var getPaymentStateCompletionClosureInput: Result<GetPaymentStatePayload, Error>?
    var getPaymentStateReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getPaymentState(data: GetPaymentStateData, completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        getPaymentStateCallsCount += 1
        let arguments = (data, completion)
        getPaymentStateReceivedArguments = arguments
        getPaymentStateReceivedInvocations.append(arguments)
        if let getPaymentStateCompletionClosureInput = getPaymentStateCompletionClosureInput {
            completion(getPaymentStateCompletionClosureInput)
        }
        return getPaymentStateReturnValue
    }
}

// MARK: - Resets

extension AcquiringPaymentsServiceMock {
    func fullReset() {
        initPaymentCallsCount = 0
        initPaymentReceivedArguments = nil
        initPaymentReceivedInvocations = []
        initPaymentCompletionClosureInput = nil

        finishAuthorizeCallsCount = 0
        finishAuthorizeReceivedArguments = nil
        finishAuthorizeReceivedInvocations = []
        finishAuthorizeCompletionClosureInput = nil

        chargeCallsCount = 0
        chargeReceivedArguments = nil
        chargeReceivedInvocations = []
        chargeCompletionClosureInput = nil

        getPaymentStateCallsCount = 0
        getPaymentStateReceivedArguments = nil
        getPaymentStateReceivedInvocations = []
        getPaymentStateCompletionClosureInput = nil
    }
}
