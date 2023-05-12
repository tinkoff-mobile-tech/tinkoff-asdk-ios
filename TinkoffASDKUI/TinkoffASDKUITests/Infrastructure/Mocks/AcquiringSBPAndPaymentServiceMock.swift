//
//  AcquiringSBPAndPaymentServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringSBPAndPaymentServiceMock: IAcquiringSBPService, IAcquiringPaymentsService {
    // MARK: - loadSBPBanks

    var loadSBPBanksCallsCount = 0
    var loadSBPBanksCompletionClosureInput: Result<GetSBPBanksPayload, Error>?

    @discardableResult
    func loadSBPBanks(completion: @escaping (Result<GetSBPBanksPayload, Error>) -> Void) -> Cancellable {
        loadSBPBanksCallsCount += 1
        if let loadSBPBanksCompletionClosureInput = loadSBPBanksCompletionClosureInput {
            completion(loadSBPBanksCompletionClosureInput)
        }
        return CancellableMock()
    }

    // MARK: - getQR

    typealias GetQRArguments = (data: GetQRData, completion: (_ result: Result<GetQRPayload, Error>) -> Void)

    var getQRCallsCount = 0
    var getQRReceivedArguments: GetQRArguments?
    var getQRReceivedInvocations: [GetQRArguments] = []
    var getQRCompletionClosureInput: Result<GetQRPayload, Error>?

    @discardableResult
    func getQR(data: GetQRData, completion: @escaping (_ result: Result<GetQRPayload, Error>) -> Void) -> Cancellable {
        getQRCallsCount += 1
        let arguments = (data, completion)
        getQRReceivedArguments = arguments
        getQRReceivedInvocations.append(arguments)
        if let getQRCompletionClosureInput = getQRCompletionClosureInput {
            completion(getQRCompletionClosureInput)
        }
        return CancellableMock()
    }

    // MARK: - initPayment

    typealias InitPaymentArguments = (data: PaymentInitData, completion: (_ result: Result<InitPayload, Error>) -> Void)

    var initPaymentCallsCount = 0
    var initPaymentReceivedArguments: InitPaymentArguments?
    var initPaymentReceivedInvocations: [InitPaymentArguments] = []
    var initPaymentCompletionClosureInput: Result<InitPayload, Error>?

    @discardableResult
    func initPayment(data: PaymentInitData, completion: @escaping (_ result: Result<InitPayload, Error>) -> Void) -> Cancellable {
        initPaymentCallsCount += 1
        let arguments = (data, completion)
        initPaymentReceivedArguments = arguments
        initPaymentReceivedInvocations.append(arguments)
        if let initPaymentCompletionClosureInput = initPaymentCompletionClosureInput {
            completion(initPaymentCompletionClosureInput)
        }
        return CancellableMock()
    }

    // MARK: - finishAuthorize

    typealias FinishAuthorizeArguments = (data: FinishAuthorizeData, completion: (_ result: Result<FinishAuthorizePayload, Error>) -> Void)

    var finishAuthorizeCallsCount = 0
    var finishAuthorizeReceivedArguments: FinishAuthorizeArguments?
    var finishAuthorizeReceivedInvocations: [FinishAuthorizeArguments] = []
    var finishAuthorizeCompletionClosureInput: Result<FinishAuthorizePayload, Error>?

    @discardableResult
    func finishAuthorize(data: FinishAuthorizeData, completion: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void) -> Cancellable {
        finishAuthorizeCallsCount += 1
        let arguments = (data, completion)
        finishAuthorizeReceivedArguments = arguments
        finishAuthorizeReceivedInvocations.append(arguments)
        if let finishAuthorizeCompletionClosureInput = finishAuthorizeCompletionClosureInput {
            completion(finishAuthorizeCompletionClosureInput)
        }
        return CancellableMock()
    }

    // MARK: - charge

    typealias ChargeArguments = (data: ChargeData, completion: (_ result: Result<ChargePayload, Error>) -> Void)

    var chargeCallsCount = 0
    var chargeReceivedArguments: ChargeArguments?
    var chargeReceivedInvocations: [ChargeArguments] = []
    var chargeCompletionClosureInput: Result<ChargePayload, Error>?

    @discardableResult
    func charge(data: ChargeData, completion: @escaping (_ result: Result<ChargePayload, Error>) -> Void) -> Cancellable {
        chargeCallsCount += 1
        let arguments = (data, completion)
        chargeReceivedArguments = arguments
        chargeReceivedInvocations.append(arguments)
        if let chargeCompletionClosureInput = chargeCompletionClosureInput {
            completion(chargeCompletionClosureInput)
        }
        return CancellableMock()
    }

    // MARK: - getPaymentState

    typealias GetPaymentStateArguments = (data: GetPaymentStateData, completion: (_ result: Result<GetPaymentStatePayload, Error>) -> Void)

    var getPaymentStateCallsCount = 0
    var getPaymentStateReceivedArguments: GetPaymentStateArguments?
    var getPaymentStateReceivedInvocations: [GetPaymentStateArguments] = []
    var getPaymentStateCompletionClosureInput: Result<GetPaymentStatePayload, Error>?

    @discardableResult
    func getPaymentState(data: GetPaymentStateData, completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        getPaymentStateCallsCount += 1
        let arguments = (data, completion)
        getPaymentStateReceivedArguments = arguments
        getPaymentStateReceivedInvocations.append(arguments)
        if let getPaymentStateCompletionClosureInput = getPaymentStateCompletionClosureInput {
            completion(getPaymentStateCompletionClosureInput)
        }
        return CancellableMock()
    }
}
