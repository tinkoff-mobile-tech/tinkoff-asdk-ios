//
//  MockPaymentProcessDelegate.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockPaymentProcessDelegate: PaymentProcessDelegate {

    // MARK: - paymentDidFinish

    struct PaymentDidFinishPassedArguments {
        let paymentProcess: PaymentProcess
        let state: TinkoffASDKCore.GetPaymentStatePayload
        let cardId: String?
        let rebillId: String?
    }

    var paymentDidFinishCallCounter = 0
    var paymentDidFinishPassedArguments: PaymentDidFinishPassedArguments?

    func paymentDidFinish(
        _ paymentProcess: PaymentProcess,
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
        let paymentProcess: PaymentProcess
        let error: Error
        let cardId: String?
        let rebillId: String?
    }

    var paymentDidFailedCallCounter = 0
    var paymentDidFailedPassedArguments: PaymentDidFailedPassedArguments?

    func paymentDidFailed(
        _ paymentProcess: PaymentProcess,
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
        let paymentProcess: PaymentProcess
        let needToCollect3DSData: TinkoffASDKCore.Checking3DSURLData
        let completion: (TinkoffASDKCore.DeviceInfoParams) -> Void
    }

    var paymentNeedCollect3DsCallCounter = 0
    var paymentNeedCollect3DsPassedArguments: PaymentNeedCollect3DsPassedArguments?

    func payment(
        _ paymentProcess: PaymentProcess,
        needToCollect3DSData checking3DSURLData: TinkoffASDKCore.Checking3DSURLData,
        completion: @escaping (TinkoffASDKCore.DeviceInfoParams) -> Void
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
        let paymentProcess: PaymentProcess
        let need3DSConfirmation: TinkoffASDKCore.Confirmation3DSData
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DsConfirmationCallCounter = 0
    var paymentNeed3DsConfirmationPassedArguments: PaymentNeed3DsConfirmationPassedArguments?

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmation data: TinkoffASDKCore.Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DsConfirmationCallCounter += 1
        paymentNeed3DsConfirmationPassedArguments = PaymentNeed3DsConfirmationPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmation: data,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )
    }

    // MARK: - payment need3DSConfirmationACS

    struct PaymentNeed3DSConfirmationACSPassedArguments {
        let paymentProcess: PaymentProcess
        let need3DSConfirmationACS: TinkoffASDKCore.Confirmation3DSDataACS
        let version: String
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DSConfirmationACSCallCounter = 0
    var paymentNeed3DSConfirmationACSPassedArguments: PaymentNeed3DSConfirmationACSPassedArguments?

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmationACS data: TinkoffASDKCore.Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DSConfirmationACSCallCounter += 1
        paymentNeed3DSConfirmationACSPassedArguments = PaymentNeed3DSConfirmationACSPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmationACS: data,
            version: version,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )
    }

    // MARK: - payment need3DSConfirmationAppBased

    struct PaymentNeed3DSConfirmationAppBasedPassedArguments {
        let paymentProcess: PaymentProcess
        let need3DSConfirmationAppBased: TinkoffASDKCore.Confirmation3DS2AppBasedData
        let version: String
        let confirmationCancelled: () -> Void
        let completion: (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    }

    var paymentNeed3DSConfirmationAppBasedCallCounter = 0
    var paymentNeed3DSConfirmationAppBasedPassedArguments: PaymentNeed3DSConfirmationAppBasedPassedArguments?

    func payment(
        _ paymentProcess: PaymentProcess,
        need3DSConfirmationAppBased data: TinkoffASDKCore.Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<TinkoffASDKCore.GetPaymentStatePayload, Error>) -> Void
    ) {
        paymentNeed3DSConfirmationAppBasedCallCounter += 1
        paymentNeed3DSConfirmationAppBasedPassedArguments = PaymentNeed3DSConfirmationAppBasedPassedArguments(
            paymentProcess: paymentProcess,
            need3DSConfirmationAppBased: data,
            version: version,
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )
    }
}
