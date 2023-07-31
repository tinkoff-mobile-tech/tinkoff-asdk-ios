//
//  SBPPaymentServiceTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPPaymentServiceTests: BaseTestCase {

    var sut: SBPPaymentService!

    // MARK: Mocks

    var acquiringSBPServiceMock: AcquiringSdkMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(with: .fakeFullRandom)
    }

    override func tearDown() {
        acquiringSBPServiceMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_loadPaymentQr_with_fullPaymentFlow_successBoth() throws {
        // given
        let paymentFlow = PaymentFlow.fakeFullRandom
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.fake
        acquiringSBPServiceMock.initPaymentCompletionClosureInput = .success(.fake)
        acquiringSBPServiceMock.getQRCompletionClosureInput = .success(anyPayload)

        var isSuccessLoaded = false
        var qrPayload: GetQRPayload?
        let completion: SBPPaymentServiceCompletion = { result in
            switch result {
            case let .success(payload):
                isSuccessLoaded = true
                qrPayload = payload
            case .failure:
                isSuccessLoaded = false
            }
        }

        // when
        sut.loadPaymentQr(completion: completion)

        // then
        XCTAssertEqual(acquiringSBPServiceMock.initPaymentCallsCount, 1)
        XCTAssertEqual(acquiringSBPServiceMock.getQRCallsCount, 1)
        XCTAssertTrue(isSuccessLoaded)
        XCTAssertEqual(qrPayload, anyPayload)
    }

    func test_loadPaymentQr_with_fullPaymentFlow_failureInit() throws {
        // given
        let paymentFlow = PaymentFlow.fakeFullRandom
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.fake
        let error = NSError(domain: "error", code: 123456)
        acquiringSBPServiceMock.initPaymentCompletionClosureInput = .failure(error)
        acquiringSBPServiceMock.getQRCompletionClosureInput = .success(anyPayload)

        var isSuccessLoaded = false
        let completion: SBPPaymentServiceCompletion = { result in
            switch result {
            case .success: isSuccessLoaded = true
            case .failure: isSuccessLoaded = false
            }
        }

        // when
        sut.loadPaymentQr(completion: completion)

        // then
        XCTAssertEqual(acquiringSBPServiceMock.initPaymentCallsCount, 1)
        XCTAssertEqual(acquiringSBPServiceMock.getQRCallsCount, 0)
        XCTAssertFalse(isSuccessLoaded)
    }

    func test_loadPaymentQr_with_fullPaymentFlow_failureGetQr() throws {
        // given
        let paymentFlow = PaymentFlow.fakeFullRandom
        setupSut(with: paymentFlow)

        let error = NSError(domain: "error", code: 123456)
        acquiringSBPServiceMock.initPaymentCompletionClosureInput = .success(.fake)
        acquiringSBPServiceMock.getQRCompletionClosureInput = .failure(error)

        var isSuccessLoaded = false
        let completion: SBPPaymentServiceCompletion = { result in
            switch result {
            case .success: isSuccessLoaded = true
            case .failure: isSuccessLoaded = false
            }
        }

        // when
        sut.loadPaymentQr(completion: completion)

        // then
        XCTAssertEqual(acquiringSBPServiceMock.initPaymentCallsCount, 1)
        XCTAssertEqual(acquiringSBPServiceMock.getQRCallsCount, 1)
        XCTAssertFalse(isSuccessLoaded)
    }

    func test_loadPaymentQr_with_finishPaymentFlow_success() throws {
        // given
        let paymentFlow = PaymentFlow.fakeFinish
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.fake
        acquiringSBPServiceMock.getQRCompletionClosureInput = .success(anyPayload)

        var isSuccessLoaded = false
        var qrPayload: GetQRPayload?
        let completion: SBPPaymentServiceCompletion = { result in
            switch result {
            case let .success(payload):
                isSuccessLoaded = true
                qrPayload = payload
            case .failure:
                isSuccessLoaded = false
            }
        }

        // when
        sut.loadPaymentQr(completion: completion)

        // then
        XCTAssertEqual(acquiringSBPServiceMock.initPaymentCallsCount, 0)
        XCTAssertEqual(acquiringSBPServiceMock.getQRCallsCount, 1)
        XCTAssertTrue(isSuccessLoaded)
        XCTAssertEqual(qrPayload, anyPayload)
    }

    func test_loadPaymentQr_with_finishPaymentFlow_failure() throws {
        // given
        let paymentFlow = PaymentFlow.fakeFinish
        setupSut(with: paymentFlow)

        let error = NSError(domain: "error", code: 123456)
        acquiringSBPServiceMock.getQRCompletionClosureInput = .failure(error)

        var isSuccessLoaded = false
        let completion: SBPPaymentServiceCompletion = { result in
            switch result {
            case .success: isSuccessLoaded = true
            case .failure: isSuccessLoaded = false
            }
        }

        // when
        sut.loadPaymentQr(completion: completion)

        // then
        XCTAssertEqual(acquiringSBPServiceMock.initPaymentCallsCount, 0)
        XCTAssertEqual(acquiringSBPServiceMock.getQRCallsCount, 1)
        XCTAssertFalse(isSuccessLoaded)
    }
}

// MARK: - Private methods

extension SBPPaymentServiceTests {
    private func setupSut(with paymentFlow: PaymentFlow) {
        acquiringSBPServiceMock = AcquiringSdkMock()
        sut = SBPPaymentService(acquiringService: acquiringSBPServiceMock, paymentFlow: paymentFlow)
    }
}
