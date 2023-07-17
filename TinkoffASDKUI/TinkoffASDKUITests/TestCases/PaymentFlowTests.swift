//
//  PaymentFlowTests.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 17.07.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class PaymentFlowTests: XCTestCase {

    func test_mergePaymentDataIfNeeded_passes_paymentCallbackURL() {
        // given
        let successURL = "https://tinkoff.ru/SuccessURL"
        let failURL = "tinkoffbank://Main/fail"
        var paymentOptions = PaymentOptions.fake()
        paymentOptions.paymentCallbackURL = PaymentCallbackURL(successURL: successURL, failureURL: failURL)
        let sut = PaymentFlow.full(paymentOptions: paymentOptions)
        // when
        let result = sut.mergePaymentDataIfNeeded(Self.tinkoffPayData)
        // then
        guard case let .full(mergedOptions) = result else { XCTFail(); return }
        XCTAssertEqual(mergedOptions.paymentCallbackURL?.successURL, successURL)
        XCTAssertEqual(mergedOptions.paymentCallbackURL?.failureURL, failURL)
    }
}

// MARK: - Constants

extension PaymentFlowTests {
    static let tinkoffPayData = ["TinkoffPayWeb": "true"]
}
