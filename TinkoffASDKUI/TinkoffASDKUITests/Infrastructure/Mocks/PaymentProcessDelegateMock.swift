//
//  PaymentProcessDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentProcessDelegateMock: PaymentProcessDelegate {

    // MARK: - paymentDidFinishWith

    typealias PaymentDidFinishWithArguments = (paymentProcess: IPaymentProcess, state: GetPaymentStatePayload, cardId: String?, rebillId: String?)

    var paymentDidFinishWithCallsCount = 0
    var paymentDidFinishWithReceivedArguments: PaymentDidFinishWithArguments?
    var paymentDidFinishWithReceivedInvocations: [PaymentDidFinishWithArguments?] = []

    func paymentDidFinish(_ paymentProcess: IPaymentProcess, with state: GetPaymentStatePayload, cardId: String?, rebillId: String?) {
        paymentDidFinishWithCallsCount += 1
        let arguments = (paymentProcess, state, cardId, rebillId)
        paymentDidFinishWithReceivedArguments = arguments
        paymentDidFinishWithReceivedInvocations.append(arguments)
    }

    // MARK: - paymentDidFailedWith

    typealias PaymentDidFailedWithArguments = (paymentProcess: IPaymentProcess, error: Error, cardId: String?, rebillId: String?)

    var paymentDidFailedWithCallsCount = 0
    var paymentDidFailedWithReceivedArguments: PaymentDidFailedWithArguments?
    var paymentDidFailedWithReceivedInvocations: [PaymentDidFailedWithArguments?] = []

    func paymentDidFailed(_ paymentProcess: IPaymentProcess, with error: Error, cardId: String?, rebillId: String?) {
        paymentDidFailedWithCallsCount += 1
        let arguments = (paymentProcess, error, cardId, rebillId)
        paymentDidFailedWithReceivedArguments = arguments
        paymentDidFailedWithReceivedInvocations.append(arguments)
    }

    // MARK: - paymentNeed3DSConfirmation

    typealias PaymentNeed3DSConfirmationArguments = (paymentProcess: IPaymentProcess, data: Confirmation3DSData, confirmationCancelled: () -> Void, completion: (Result<GetPaymentStatePayload, Error>) -> Void)

    var paymentNeed3DSConfirmationCallsCount = 0
    var paymentNeed3DSConfirmationReceivedArguments: PaymentNeed3DSConfirmationArguments?
    var paymentNeed3DSConfirmationReceivedInvocations: [PaymentNeed3DSConfirmationArguments?] = []
    var paymentNeed3DSConfirmationConfirmationCancelledShouldExecute = false
    var paymentNeed3DSConfirmationCompletionClosureInput: Result<GetPaymentStatePayload, Error>?

    func payment(_ paymentProcess: IPaymentProcess, need3DSConfirmation data: Confirmation3DSData, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        paymentNeed3DSConfirmationCallsCount += 1
        let arguments = (paymentProcess, data, confirmationCancelled, completion)
        paymentNeed3DSConfirmationReceivedArguments = arguments
        paymentNeed3DSConfirmationReceivedInvocations.append(arguments)
        if paymentNeed3DSConfirmationConfirmationCancelledShouldExecute {
            confirmationCancelled()
        }
        if let paymentNeed3DSConfirmationCompletionClosureInput = paymentNeed3DSConfirmationCompletionClosureInput {
            completion(paymentNeed3DSConfirmationCompletionClosureInput)
        }
    }

    // MARK: - paymentNeedToCollect3DSData

    typealias PaymentNeedToCollect3DSDataArguments = (paymentProcess: IPaymentProcess, checking3DSURLData: Checking3DSURLData, completion: (ThreeDsDataBrowser) -> Void)

    var paymentNeedToCollect3DSDataCallsCount = 0
    var paymentNeedToCollect3DSDataReceivedArguments: PaymentNeedToCollect3DSDataArguments?
    var paymentNeedToCollect3DSDataReceivedInvocations: [PaymentNeedToCollect3DSDataArguments?] = []
    var paymentNeedToCollect3DSDataCompletionClosureInput: ThreeDsDataBrowser?

    func payment(_ paymentProcess: IPaymentProcess, needToCollect3DSData checking3DSURLData: Checking3DSURLData, completion: @escaping (ThreeDsDataBrowser) -> Void) {
        paymentNeedToCollect3DSDataCallsCount += 1
        let arguments = (paymentProcess, checking3DSURLData, completion)
        paymentNeedToCollect3DSDataReceivedArguments = arguments
        paymentNeedToCollect3DSDataReceivedInvocations.append(arguments)
        if let paymentNeedToCollect3DSDataCompletionClosureInput = paymentNeedToCollect3DSDataCompletionClosureInput {
            completion(paymentNeedToCollect3DSDataCompletionClosureInput)
        }
    }

    // MARK: - paymentNeed3DSConfirmationACS

    typealias PaymentNeed3DSConfirmationACSArguments = (paymentProcess: IPaymentProcess, data: Confirmation3DSDataACS, version: String, confirmationCancelled: () -> Void, completion: (Result<GetPaymentStatePayload, Error>) -> Void)

    var paymentNeed3DSConfirmationACSCallsCount = 0
    var paymentNeed3DSConfirmationACSReceivedArguments: PaymentNeed3DSConfirmationACSArguments?
    var paymentNeed3DSConfirmationACSReceivedInvocations: [PaymentNeed3DSConfirmationACSArguments?] = []
    var paymentNeed3DSConfirmationACSConfirmationCancelledShouldExecute = false
    var paymentNeed3DSConfirmationACSCompletionClosureInput: Result<GetPaymentStatePayload, Error>?

    func payment(_ paymentProcess: IPaymentProcess, need3DSConfirmationACS data: Confirmation3DSDataACS, version: String, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        paymentNeed3DSConfirmationACSCallsCount += 1
        let arguments = (paymentProcess, data, version, confirmationCancelled, completion)
        paymentNeed3DSConfirmationACSReceivedArguments = arguments
        paymentNeed3DSConfirmationACSReceivedInvocations.append(arguments)
        if paymentNeed3DSConfirmationACSConfirmationCancelledShouldExecute {
            confirmationCancelled()
        }
        if let paymentNeed3DSConfirmationACSCompletionClosureInput = paymentNeed3DSConfirmationACSCompletionClosureInput {
            completion(paymentNeed3DSConfirmationACSCompletionClosureInput)
        }
    }

    // MARK: - startAppBasedFlowCheck3dsPayload

    typealias StartAppBasedFlowCheck3dsPayloadArguments = (check3dsPayload: Check3DSVersionPayload, completion: (Result<ThreeDsDataSDK, Error>) -> Void)

    var startAppBasedFlowCheck3dsPayloadCallsCount = 0
    var startAppBasedFlowCheck3dsPayloadReceivedArguments: StartAppBasedFlowCheck3dsPayloadArguments?
    var startAppBasedFlowCheck3dsPayloadReceivedInvocations: [StartAppBasedFlowCheck3dsPayloadArguments?] = []
    var startAppBasedFlowCheck3dsPayloadCompletionClosureInput: Result<ThreeDsDataSDK, Error>?

    func startAppBasedFlow(check3dsPayload: Check3DSVersionPayload, completion: @escaping (Result<ThreeDsDataSDK, Error>) -> Void) {
        startAppBasedFlowCheck3dsPayloadCallsCount += 1
        let arguments = (check3dsPayload, completion)
        startAppBasedFlowCheck3dsPayloadReceivedArguments = arguments
        startAppBasedFlowCheck3dsPayloadReceivedInvocations.append(arguments)
        if let startAppBasedFlowCheck3dsPayloadCompletionClosureInput = startAppBasedFlowCheck3dsPayloadCompletionClosureInput {
            completion(startAppBasedFlowCheck3dsPayloadCompletionClosureInput)
        }
    }

    // MARK: - paymentNeed3DSConfirmationAppBased

    typealias PaymentNeed3DSConfirmationAppBasedArguments = (paymentProcess: IPaymentProcess, data: Confirmation3DS2AppBasedData, version: String, confirmationCancelled: () -> Void, completion: (Result<GetPaymentStatePayload, Error>) -> Void)

    var paymentNeed3DSConfirmationAppBasedCallsCount = 0
    var paymentNeed3DSConfirmationAppBasedReceivedArguments: PaymentNeed3DSConfirmationAppBasedArguments?
    var paymentNeed3DSConfirmationAppBasedReceivedInvocations: [PaymentNeed3DSConfirmationAppBasedArguments?] = []
    var paymentNeed3DSConfirmationAppBasedConfirmationCancelledShouldExecute = false
    var paymentNeed3DSConfirmationAppBasedCompletionClosureInput: Result<GetPaymentStatePayload, Error>?

    func payment(_ paymentProcess: IPaymentProcess, need3DSConfirmationAppBased data: Confirmation3DS2AppBasedData, version: String, confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void) {
        paymentNeed3DSConfirmationAppBasedCallsCount += 1
        let arguments = (paymentProcess, data, version, confirmationCancelled, completion)
        paymentNeed3DSConfirmationAppBasedReceivedArguments = arguments
        paymentNeed3DSConfirmationAppBasedReceivedInvocations.append(arguments)
        if paymentNeed3DSConfirmationAppBasedConfirmationCancelledShouldExecute {
            confirmationCancelled()
        }
        if let paymentNeed3DSConfirmationAppBasedCompletionClosureInput = paymentNeed3DSConfirmationAppBasedCompletionClosureInput {
            completion(paymentNeed3DSConfirmationAppBasedCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension PaymentProcessDelegateMock {
    func fullReset() {
        paymentDidFinishWithCallsCount = 0
        paymentDidFinishWithReceivedArguments = nil
        paymentDidFinishWithReceivedInvocations = []

        paymentDidFailedWithCallsCount = 0
        paymentDidFailedWithReceivedArguments = nil
        paymentDidFailedWithReceivedInvocations = []

        paymentNeed3DSConfirmationCallsCount = 0
        paymentNeed3DSConfirmationReceivedArguments = nil
        paymentNeed3DSConfirmationReceivedInvocations = []
        paymentNeed3DSConfirmationConfirmationCancelledShouldExecute = false
        paymentNeed3DSConfirmationCompletionClosureInput = nil

        paymentNeedToCollect3DSDataCallsCount = 0
        paymentNeedToCollect3DSDataReceivedArguments = nil
        paymentNeedToCollect3DSDataReceivedInvocations = []
        paymentNeedToCollect3DSDataCompletionClosureInput = nil

        paymentNeed3DSConfirmationACSCallsCount = 0
        paymentNeed3DSConfirmationACSReceivedArguments = nil
        paymentNeed3DSConfirmationACSReceivedInvocations = []
        paymentNeed3DSConfirmationACSConfirmationCancelledShouldExecute = false
        paymentNeed3DSConfirmationACSCompletionClosureInput = nil

        startAppBasedFlowCheck3dsPayloadCallsCount = 0
        startAppBasedFlowCheck3dsPayloadReceivedArguments = nil
        startAppBasedFlowCheck3dsPayloadReceivedInvocations = []
        startAppBasedFlowCheck3dsPayloadCompletionClosureInput = nil

        paymentNeed3DSConfirmationAppBasedCallsCount = 0
        paymentNeed3DSConfirmationAppBasedReceivedArguments = nil
        paymentNeed3DSConfirmationAppBasedReceivedInvocations = []
        paymentNeed3DSConfirmationAppBasedConfirmationCancelledShouldExecute = false
        paymentNeed3DSConfirmationAppBasedCompletionClosureInput = nil
    }
}
