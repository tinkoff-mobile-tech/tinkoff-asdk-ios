//
//  CardRequisitesMasksResolverTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 26.06.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class CardRequisitesMasksResolverTests: XCTestCase {
    // MARK: Properties

    private var sut: CardRequisitesMasksResolver!
    private var paymentSystemResolverMock: PaymentSystemResolverMock!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        sut = CardRequisitesMasksResolver(
            paymentSystemResolver: paymentSystemResolverMock
        )
    }

    override func tearDown() {
        paymentSystemResolverMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatResolverCreatesPanMask_whenPaymentSystemIsVisa() {
        test_resolver(with: .resolved(.visa), pan: .visa, expectedResult: .digits16)
    }

    func test_thatResolverCreatesPanMask_whenPaymentSystemIsMasterCard() {
        test_resolver(with: .resolved(.masterCard), pan: .masterCard, expectedResult: .digits16)
    }

    func test_thatResolverCreatesPanMaskForMirPaymentSystem_whenNumberOfDigitsIs17() {
        let pan = String(String.mir.prefix(17))
        test_resolver(with: .resolved(.mir), pan: pan, expectedResult: continuousDigits(length: 19))
    }

    func test_thatResolverCreatesPanMaskForMirPaymentSystem_whenNumberOfDigitsIs18() {
        let pan = String(String.mir.prefix(18))
        test_resolver(with: .resolved(.mir), pan: pan, expectedResult: continuousDigits(length: 19))
    }

    func test_thatResolverCreatesPanMaskForMirPaymentSystem_whenNumberOfDigitsIs15() {
        let pan = String(String.mir.prefix(15))
        test_resolver(with: .resolved(.mir), pan: pan, expectedResult: "[0000] [0000] [0000] [0000][0000]")
    }

    func test_thatResolverCreatesPanMaskForMirPaymentSystem_whenNumberOfDigitsIs20() {
        let pan = String.digits20
        test_resolver(with: .resolved(.mir), pan: pan, expectedResult: .digits19)
    }

    func test_thatResolverCreatesPanMaskForUnionPayPaymentSystem_whenNumberOfDigitsIs17() {
        let pan = String(String.digits20.prefix(17))
        test_resolver(with: .resolved(.unionPay), pan: pan, expectedResult: continuousDigits(length: 19))
    }

    func test_thatResolverCreatesPanMaskForUnionPayPaymentSystem_whenNumberOfDigitsIs18() {
        let pan = String(String.digits20.prefix(18))
        test_resolver(with: .resolved(.unionPay), pan: pan, expectedResult: continuousDigits(length: 19))
    }

    func test_thatResolverCreatesPanMaskForUnionPayPaymentSystem_whenNumberOfDigitsIs15() {
        let pan = String(String.unionPay.prefix(15))
        test_resolver(with: .resolved(.unionPay), pan: pan, expectedResult: "[0000] [0000] [0000] [0000][0000]")
    }

    func test_thatResolverCreatesPanMaskForUnionPayPaymentSystem_whenNumberOfDigitsIs20() {
        let pan = continuousDigits(length: 20)
        test_resolver(with: .resolved(.mir), pan: pan, expectedResult: .digits19)
    }

    func test_thatResolverCreatesPanMaskForMaestroPaymentSystem_whenNumberOfDigitsIs13() {
        let pan = String(String.maestro.prefix(13))
        test_resolver(with: .resolved(.maestro), pan: pan, expectedResult: "[0000] [0000] [00000][000000]")
    }

    func test_thatResolverCreatesPanMaskForMaestroPaymentSystem_whenNumberOfDigitsIs15() {
        let pan = String(String.maestro.prefix(15))
        test_resolver(with: .resolved(.maestro), pan: pan, expectedResult: "[0000] [000000] [0000][0000]")
    }

    func test_thatResolverCreatesPanMaskForMaestroPaymentSystem_whenNumberOfDigitsIs16() {
        let pan = String(String.maestro.prefix(16))
        test_resolver(with: .resolved(.maestro), pan: pan, expectedResult: "[0000] [0000] [0000] [0000][000]")
    }

    func test_thatResolverCreatesPanMaskForMaestroPaymentSystem_whenNumberOfDigitsIs19() {
        let pan = String(String.digits20.prefix(19))
        test_resolver(with: .resolved(.maestro), pan: pan, expectedResult: .digits19)
    }

    func test_thatResolverCreatesPanMaskForMaestroPaymentSystem_whenNumberOfDigitsIs20() {
        test_resolver(with: .resolved(.maestro), pan: .digits20, expectedResult: continuousDigits(length: 19))
    }

    func test_thatResolverCreatesDefaultMask_whenPaymentSystemIsAmbiguous() {
        let pan = "67596498264384531321"
        test_resolver(with: .ambiguous, pan: pan, expectedResult: continuousDigits(length: 28))
    }

    func test_thatResolverCreatesDefaultMask_whenPaymentSystemIsUnrecognized() {
        let pan = "67596498264384531321"
        test_resolver(with: .unrecognized, pan: pan, expectedResult: continuousDigits(length: 28))
    }

    func test_thatResolverHasCorrectCVCMask() {
        // when
        let mask = sut.cvcMask

        // then
        XCTAssertEqual(mask, .cvc)
    }

    func test_thatResolverHasCorrectThru() {
        // when
        let mask = sut.validThruMask

        // then
        XCTAssertEqual(mask, .validThru)
    }

    // MARK: Private

    private func test_resolver(
        with paymentSystem: PaymentSystemDecision,
        pan: String,
        expectedResult: String
    ) {
        // given
        paymentSystemResolverMock.resolveReturnValue = paymentSystem

        // when
        let result = sut.panMask(for: pan)

        // then
        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(paymentSystemResolverMock.resolveReceivedArguments, pan)
    }

    private func continuousDigits(length: Int) -> String {
        guard length > .zero else { return "" }
        return "[\(String(repeating: "0", count: length))]"
    }
}

// MARK: - Constants

private extension String {
    static let digits16 = "[0000] [0000] [0000] [0000]"
    static let digits19 = "[000000] [0000000000000]"

    static let maestro = "6759649826438453"
    static let unionPay = "6210946888090005"
    static let masterCard = "5555555555554444"
    static let visa = "4000060000000006"
    static let mir = "22001234556789010"
    static let americanExpress = "378282246310005"

    static let digits20 = "67596498264384531321"

    static let validThru = "[00]/[00]"
    static let cvc = "[000]"
}
