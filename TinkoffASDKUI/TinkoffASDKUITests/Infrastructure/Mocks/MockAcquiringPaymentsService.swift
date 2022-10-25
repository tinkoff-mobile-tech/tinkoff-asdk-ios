//
//  MockAcquiringPayments.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockAcquiringPaymentsService: IAcquiringPaymentsService {

    // MARK: - initPayment

    struct InitPaymentPassedArguments {
        let data: PaymentInitData
        let completion: (Result<InitPayload, Error>) -> Void
    }

    var initPaymentCallCounter = 0
    var initPaymentPassedArguments: InitPaymentPassedArguments?
    var initPaymentStubReturn: ((InitPaymentPassedArguments) -> Cancellable) = { _ in EmptyCancellable() }

    func initPayment(data: PaymentInitData, completion: @escaping (Result<InitPayload, Error>) -> Void) -> Cancellable {
        initPaymentCallCounter += 1
        let args = InitPaymentPassedArguments(data: data, completion: completion)
        initPaymentPassedArguments = args
        return initPaymentStubReturn(args)
    }

    // MARK: - finishAuthorize

    struct FinishAuthorizePassedArguments {
        let data: FinishAuthorizeData
        let completion: (Result<FinishAuthorizePayload, Error>) -> Void
    }

    var finishAuthorizeCallCounter = 0
    var finishAuthorizePassedArguments: FinishAuthorizePassedArguments?
    var finishAuthorizeStubReturn: ((FinishAuthorizePassedArguments) -> Cancellable) = { _ in EmptyCancellable() }

    func finishAuthorize(data: FinishAuthorizeData, completion: @escaping (Result<FinishAuthorizePayload, Error>) -> Void) -> Cancellable {
        finishAuthorizeCallCounter += 1
        let args = FinishAuthorizePassedArguments(data: data, completion: completion)
        finishAuthorizePassedArguments = args
        return finishAuthorizeStubReturn(args)
    }

    // MARK: - charge

    struct ChargePassedArguments {
        let data: ChargeData
        let completion: (Result<ChargePayload, Error>) -> Void
    }

    var chargeCallCounter = 0
    var chargePassedArguments: ChargePassedArguments?
    var chargeStubReturn: ((ChargePassedArguments) -> Cancellable) = { _ in EmptyCancellable() }

    func charge(data: ChargeData, completion: @escaping (Result<ChargePayload, Error>) -> Void) -> Cancellable {
        chargeCallCounter += 1
        let args = ChargePassedArguments(data: data, completion: completion)
        chargePassedArguments = args
        return chargeStubReturn(args)
    }
}
