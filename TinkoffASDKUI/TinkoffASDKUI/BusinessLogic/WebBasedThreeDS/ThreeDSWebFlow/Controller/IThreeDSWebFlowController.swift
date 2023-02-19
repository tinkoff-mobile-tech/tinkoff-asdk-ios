//
//  IThreeDSWebFlowController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol IThreeDSWebFlowController: AnyObject {
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws

    func confirm3DS<Payload: Decodable>(
        data: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    )

    func confirm3DSACS<Payload: Decodable>(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    )
}

// MARK: - IThreeDSWebFlowController + Payment Flow

extension IThreeDSWebFlowController {
    func confirm3DS(
        paymentConfirmationData: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        confirm3DS(data: paymentConfirmationData, completion: completion)
    }

    func confirm3DSACS(
        paymentConfirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        confirm3DSACS(data: paymentConfirmationData, messageVersion: messageVersion, completion: completion)
    }
}

// MARK: - IThreeDSWebFlowController + Add Card Flow

extension IThreeDSWebFlowController {
    func confirm3DS(
        addCardConfirmationData: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetAddCardStatePayload>) -> Void
    ) {
        confirm3DS(data: addCardConfirmationData, completion: completion)
    }

    func confirm3DSACS(
        addCardConfirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetAddCardStatePayload>) -> Void
    ) {
        confirm3DSACS(data: addCardConfirmationData, messageVersion: messageVersion, completion: completion)
    }
}
