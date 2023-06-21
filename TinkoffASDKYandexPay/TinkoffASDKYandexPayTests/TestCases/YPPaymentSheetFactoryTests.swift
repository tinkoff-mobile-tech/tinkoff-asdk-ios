//
//  YPPaymentSheetFactoryTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 23.05.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YPPaymentSheetFactoryTests: BaseTestCase {

    var sut: YPPaymentSheetFactory!

    let fakeYPMethod = YandexPayMethod.fake()

    // MARK: - Setup

    override func setUp() {
        sut = YPPaymentSheetFactory(method: fakeYPMethod)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_create_full_flow_sucess() {
        allureId(2358063, "Успешная инициализация шторки YP при нажатии кнопки")

        // given
        let flow = PaymentFlow.full(paymentOptions: .fake())
        let cardMethod = formCardMethod()

        // when
        let ypSheet = sut.create(with: flow)

        // then
        var id = ""
        var orderAmount: Int64 = .zero
        if case let .full(paymentOptions) = flow {
            id = fakeYPMethod.merchantId + paymentOptions.orderOptions.orderId
            orderAmount = paymentOptions.orderOptions.amount
        }

        XCTAssertEqual(ypSheet.countryCode, .ru)
        XCTAssertEqual(ypSheet.currencyCode, .rub)
        XCTAssertEqual(ypSheet.order.id, id)
        XCTAssertEqual(ypSheet.order.amount, "\(Double(orderAmount) / 100)")
        XCTAssertEqual(ypSheet.paymentMethods, [.card(cardMethod)])
    }

    func test_create_finish_flow_sucess() {
        // given
        let flow = PaymentFlow.finish(paymentOptions: .fake())
        let cardMethod = formCardMethod()

        // when
        let ypSheet = sut.create(with: flow)

        // then
        var id = ""
        var orderAmount: Int64 = .zero
        if case let .finish(paymentOptions) = flow {
            id = fakeYPMethod.merchantId + paymentOptions.orderId
            orderAmount = paymentOptions.amount
        }

        XCTAssertEqual(ypSheet.countryCode, .ru)
        XCTAssertEqual(ypSheet.currencyCode, .rub)
        XCTAssertEqual(ypSheet.order.id, id)
        XCTAssertEqual(ypSheet.order.amount, "\(Double(orderAmount) / 100)")
        XCTAssertEqual(ypSheet.paymentMethods, [.card(cardMethod)])
    }
}

extension YPPaymentSheetFactoryTests {

    private func formCardMethod() -> YPCardPaymentMethod {
        YPCardPaymentMethod(
            gateway: "tinkoff",
            gatewayMerchantId: fakeYPMethod.merchantId,
            allowedAuthMethods: [.panOnly],
            allowedCardNetworks: [.visa, .mastercard, .mir]
        )
    }
}
