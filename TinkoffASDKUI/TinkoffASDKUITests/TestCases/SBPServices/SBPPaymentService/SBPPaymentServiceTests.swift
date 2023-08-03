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

    var acquiringSBPServiceMock: AcquiringSBPAndPaymentServiceMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(with: .fullRandom)
    }

    override func tearDown() {
        acquiringSBPServiceMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_loadPaymentQr_with_fullPaymentFlow_successBoth() throws {
        // given
        let paymentFlow = PaymentFlow.fullRandom
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.any
        acquiringSBPServiceMock.initPaymentCompletionClosureInput = .success(.any)
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
        let paymentFlow = PaymentFlow.fullRandom
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.any
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
        let paymentFlow = PaymentFlow.fullRandom
        setupSut(with: paymentFlow)

        let error = NSError(domain: "error", code: 123456)
        acquiringSBPServiceMock.initPaymentCompletionClosureInput = .success(.any)
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
        let paymentFlow = PaymentFlow.finishAny
        setupSut(with: paymentFlow)

        let anyPayload = GetQRPayload.any
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
        let paymentFlow = PaymentFlow.finishAny
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

extension InitPayload {
    static let any = InitPayload(
        amount: 324,
        orderId: "324234",
        paymentId: "2222",
        status: .authorized
    )
}

extension SBPPaymentServiceTests {
    private func setupSut(with paymentFlow: PaymentFlow) {
        acquiringSBPServiceMock = AcquiringSBPAndPaymentServiceMock()
        sut = SBPPaymentService(acquiringService: acquiringSBPServiceMock, paymentFlow: paymentFlow)
    }
}

extension PaymentFlow {
    static var fullRandom: PaymentFlow {
        let amount = 2000
        let randomOrderId = String(Int64.random(in: 1000 ... 10000))
        var paymentData = PaymentInitData(amount: NSDecimalNumber(value: amount), orderId: randomOrderId, customerKey: "any key")
        paymentData.description = "Краткое описание товара"

        let receiptItems: [Item] = []

        paymentData.receipt = .version1_05(
            ReceiptFdv1_05(
                shopCode: nil,
                email: "email@email.com",
                taxation: .osn,
                phone: "+79876543210",
                items: receiptItems,
                agentData: nil,
                supplierInfo: nil
            )
        )

        let paymentOptions = PaymentOptions.create(from: paymentData)
        return PaymentFlow.full(paymentOptions: paymentOptions)
    }

    static var finishAny: PaymentFlow {
        let customerOptions = CustomerOptions(customerKey: "somekey", email: "someemail")
        let options = FinishPaymentOptions(paymentId: "32423", amount: 100, orderId: "id", customerOptions: customerOptions)
        return PaymentFlow.finish(paymentOptions: options)
    }
}

private extension PaymentOptions {
    static func create(from initData: PaymentInitData) -> PaymentOptions {
        let orderOptions = OrderOptions(
            orderId: initData.orderId,
            amount: initData.amount,
            description: initData.description,
            receipt: initData.receipt,
            shops: initData.shops,
            receipts: initData.receipts,
            savingAsParentPayment: initData.savingAsParentPayment ?? false
        )

        let customerOptions = initData.customerKey.map {
            CustomerOptions(customerKey: $0, email: "exampleEmail@tinkoff.ru")
        }

        return PaymentOptions(
            orderOptions: orderOptions,
            customerOptions: customerOptions,
            paymentData: initData.paymentFormData ?? [:]
        )
    }
}
