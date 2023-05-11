//
//  PaymentProcessDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol PaymentProcessDelegate: AnyObject {
    func paymentDidFinish(
        _ paymentProcess: IPaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    )
    func paymentDidFailed(
        _ paymentProcess: IPaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    )
    func payment(
        _ paymentProcess: IPaymentProcess,
        needToCollect3DSData checking3DSURLData: Checking3DSURLData,
        completion: @escaping (ThreeDSDeviceInfo) -> Void
    )
    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmation data: Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )
    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationACS data: Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )

    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationAppBased data: Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )
}
