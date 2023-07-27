//
//  PaymentStatusServiceTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 12.05.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentStatusServiceTests: BaseTestCase {

    var sut: PaymentStatusService!

    // MARK: Mocks

    var paymentServiceMock: AcquiringSdkMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        paymentServiceMock = AcquiringSdkMock()
        sut = PaymentStatusService(paymentService: paymentServiceMock)
    }

    override func tearDown() {
        paymentServiceMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_getPaymentState_success() {
        // given
        let paymentId = "123456"
        let payload = GetPaymentStatePayload.fake()
        paymentServiceMock.getPaymentStateCompletionClosureInput = .success(payload)

        var isSuccessLoaded = false
        var loadedPayload: GetPaymentStatePayload?
        let completion: PaymentStatusServiceCompletion = { result in
            switch result {
            case let .success(payload):
                isSuccessLoaded = true
                loadedPayload = payload
            case .failure:
                isSuccessLoaded = false
            }
        }

        // when
        sut.getPaymentState(paymentId: paymentId, completion: completion)

        // then
        XCTAssertTrue(isSuccessLoaded)
        XCTAssertEqual(loadedPayload, payload)
        XCTAssertEqual(paymentServiceMock.getPaymentStateCallsCount, 1)
    }

    func test_getPaymentState_failure() {
        // given
        let paymentId = "123456"
        let error = NSError(domain: "error", code: 123456)
        paymentServiceMock.getPaymentStateCompletionClosureInput = .failure(error)

        var isSuccessLoaded = false
        let completion: PaymentStatusServiceCompletion = { result in
            switch result {
            case .success: isSuccessLoaded = true
            case .failure: isSuccessLoaded = false
            }
        }

        // when
        sut.getPaymentState(paymentId: paymentId, completion: completion)

        // then
        XCTAssertFalse(isSuccessLoaded)
        XCTAssertEqual(paymentServiceMock.getPaymentStateCallsCount, 1)
    }
}
