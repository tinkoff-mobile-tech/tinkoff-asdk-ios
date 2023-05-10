//
//  PaymentProcessDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentProcessDelegateMock: PaymentProcessDelegate {

    // MARK: - paymentDidFinish

    struct PaymentDidFinishPassedArguments {
        let paymentProcess: IPaymentProcess
        let state: TinkoffASDKCore.GetPaymentStatePayload
        let cardId: String?
        let rebillId: String?
    }

    var paymentDidFinishCallCounter = 0
    var paymentDidFinishPassedArguments: PaymentDidFinishPassedArguments?

    func paymentDidFinish(
        _ paymentProcess: IPaymentProcess,
        with state: TinkoffASDKCore.GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        paymentDidFinishCallCounter += 1
        paymentDidFinishPassedArguments = PaymentDidFinishPassedArguments(
            paymentProcess: paymentProcess,
            state: state,
            cardId: cardId,
            rebillId: rebillId
        )
    }

    // MARK: - paymentDidFailed

    struct PaymentDidFailedPassedArguments {
        let paymentProcess: IPaymentProcess
        let error: Error
        let cardId: String?
        let rebillId: String?
    }

    var paymentDidFailedCallCounter = 0
    var paymentDidFailedPassedArguments: PaymentDidFailedPassedArguments?

    func paymentDidFailed(
        _ paymentProcess: IPaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        paymentDidFailedCallCounter += 1
        paymentDidFailedPassedArguments = PaymentDidFailedPassedArguments(
            paymentProcess: paymentProcess,
            error: error,
            cardId: cardId,
            rebillId: rebillId
        )
    }

    // MARK: - payment need to collect 3ds data

    struct PaymentNeedCollect3DsPassedArguments {
        let paymentProcess: IPaymentProcess
        let needToCollect3DSData: TinkoffASDKCore.Checking3DSURLData
        let completion: (TinkoffASDKCore.ThreeDSDeviceInfo) -> Void
    }

    var paymentNeedCollect3DsCallCounter = 0
    var paymentNeedCollect3DsPassedArguments: PaymentNeedCollect3DsPassedArguments?

    func payment(
        _ paymentProcess: IPaymentProcess,
        needToCollect3DSData checking3DSURLData: TinkoffASDKCore.Checking3DSURLData,
        completion: @escaping (TinkoffASDKCore.ThreeDSDeviceInfo) -> Void
    ) {
        paymentNeedCollect3DsCallCounter += 1
        paymentNeedCollect3DsPassedArguments = PaymentNeedCollect3DsPassedArguments(
            paymentProcess: paymentProcess,
            needToCollect3DSData: checking3DSURLData,
            completion: completion
        )
    }

    // MARK: - payment need 3ds confirmation

    struct PaymentNeed3DsConfirmationPassedArguments {
        let paymentProcess: IPaymentProcess
        let need3DSConfirmation: TinkoffASDKCore.Confirmation3DSData
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DsConfirmationCallCounter = 0
    var paymentNeed3DsConfirmationPassedArguments: PaymentNeed3DsConfirmationPassedArguments?
    var paymentNeed3DsConfirmationCompletionInput: Result<GetPaymentStatePayload, Error>?
    var paymentNeed3DsConfirmationCancelledInput: Void?

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmation data: TinkoffASDKCore.Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DsConfirmationCallCounter += 1
        paymentNeed3DsConfirmationPassedArguments = PaymentNeed3DsConfirmationPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmation: data,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )

        if let _ = paymentNeed3DsConfirmationCancelledInput {
            confirmationCancelled()
        }

        if let paymentNeed3DsConfirmationCompletionInput = paymentNeed3DsConfirmationCompletionInput {
            completion(paymentNeed3DsConfirmationCompletionInput)
        }
    }

    // MARK: - payment need3DSConfirmationACS

    struct PaymentNeed3DSConfirmationACSPassedArguments {
        let paymentProcess: IPaymentProcess
        let need3DSConfirmationACS: TinkoffASDKCore.Confirmation3DSDataACS
        let version: String
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DSConfirmationACSCallCounter = 0
    var paymentNeed3DSConfirmationACSPassedArguments: PaymentNeed3DSConfirmationACSPassedArguments?
    var paymentNeed3DSConfirmationACSConfirmationCancelledInput: Void?
    var paymentNeed3DSConfirmationACSCompletionInput: Result<GetPaymentStatePayload, Error>?

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationACS data: TinkoffASDKCore.Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DSConfirmationACSCallCounter += 1
        paymentNeed3DSConfirmationACSPassedArguments = PaymentNeed3DSConfirmationACSPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmationACS: data,
            version: version,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )

        if let _ = paymentNeed3DSConfirmationACSConfirmationCancelledInput {
            confirmationCancelled()
        }

        if let input = paymentNeed3DSConfirmationACSCompletionInput {
            completion(input)
        }
    }

    // MARK: - payment need3DSConfirmationAppBased

    struct PaymentNeed3DSConfirmationAppBasedPassedArguments {
        let paymentProcess: IPaymentProcess
        let need3DSConfirmationAppBased: TinkoffASDKCore.Confirmation3DS2AppBasedData
        let version: String
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DSConfirmationAppBasedCallCounter = 0
    var paymentNeed3DSConfirmationAppBasedPassedArguments: PaymentNeed3DSConfirmationAppBasedPassedArguments?
    var paymentNeed3DSConfirmationAppBasedConfirmationCancelledInput: Void?
    var paymentNeed3DSConfirmationAppBasedCompletionInput: Result<GetPaymentStatePayload, Error>?

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationAppBased data: TinkoffASDKCore.Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DSConfirmationAppBasedCallCounter += 1
        paymentNeed3DSConfirmationAppBasedPassedArguments = PaymentNeed3DSConfirmationAppBasedPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmationAppBased: data,
            version: version,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )

        if let _ = paymentNeed3DSConfirmationAppBasedConfirmationCancelledInput {
            confirmationCancelled()
        }

        if let input = paymentNeed3DSConfirmationAppBasedCompletionInput {
            completion(input)
        }
    }
}
