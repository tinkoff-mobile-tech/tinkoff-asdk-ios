//
//  MaskedTextFieldDelegateTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 01.06.2023.
//

@testable import TinkoffASDKUI
import UIKit
import XCTest

final class MaskedTextFieldDelegateTests: BaseTestCase {

    let textField = UITextField()

    // Mocks
    var listenerMock: MaskedTextFieldDelegateListenerMock!
    var inputMaskResolver: ICardRequisitesMasksResolver!

    // MARK: - Setup

    override func setUp() {
        listenerMock = MaskedTextFieldDelegateListenerMock()
        inputMaskResolver = CardRequisitesMasksResolver(paymentSystemResolver: PaymentSystemResolver())
        super.setUp()
    }

    override func tearDown() {
        listenerMock = nil
        inputMaskResolver = nil
        textField.delegate = nil
        textField.text = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_mir_filled_card_number() {
        allureId(2559802, "Курсор не перемещается после ввода номера карт МИР и UP")

        // given
        let sut = prepareCardNumberSut(cardNumber: .mirValidCardNumber)

        // when
        sut.put(text: .mirValidCardNumber, into: textField)

        // then
        XCTAssertEqual(listenerMock.textFieldCallsCount, 1)
        XCTAssert(listenerMock.textFieldReceivedArguments?.textField === textField)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.complete, false)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.value, .mirValidCardNumber)

        // when
        sut.put(text: .mirMaxValidCardNumber, into: textField)

        // then
        XCTAssertEqual(listenerMock.textFieldCallsCount, 2)
        XCTAssert(listenerMock.textFieldReceivedArguments?.textField === textField)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.complete, true)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.value, .mirMaxValidCardNumber)
    }

    func test_union_pay_filled_card_number() {
        allureId(2559802, "Курсор не перемещается после ввода номера карт МИР и UP")

        // given
        let sut = prepareCardNumberSut(cardNumber: .unionPayValidCardNumber)

        // when
        sut.put(text: .unionPayValidCardNumber, into: textField)

        // then
        XCTAssertEqual(listenerMock.textFieldCallsCount, 1)
        XCTAssert(listenerMock.textFieldReceivedArguments?.textField === textField)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.complete, false)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.value, .unionPayValidCardNumber)

        // when
        sut.put(text: .unionPayMaxValidCardNumber, into: textField)

        // then
        XCTAssertEqual(listenerMock.textFieldCallsCount, 2)
        XCTAssert(listenerMock.textFieldReceivedArguments?.textField === textField)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.complete, true)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.value, .unionPayMaxValidCardNumber)
    }

    func test_valid_card_number_fills_field() {
        allureId(2559796, "После ввода валидных данных карты курсор перемещается на поле ввода срока")

        // given
        let cardNumber = "5340962355918342"
        let sut = prepareCardNumberSut(cardNumber: cardNumber)

        // when
        sut.put(text: cardNumber, into: textField)

        // then
        XCTAssertEqual(listenerMock.textFieldCallsCount, 1)
        XCTAssert(listenerMock.textFieldReceivedArguments?.textField === textField)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.complete, true)
        XCTAssertEqual(listenerMock.textFieldReceivedArguments?.value, cardNumber)
    }
}

private extension String {
    static let mirValidCardNumber = "2201382000000047"
    static let unionPayValidCardNumber = "6263015600105925"

    static let mirMaxValidCardNumber = "2201382000000047222"
    static let unionPayMaxValidCardNumber = "6263015600105925222"
}

extension MaskedTextFieldDelegateTests {

    private func prepareCardNumberSut(cardNumber: String) -> MaskedTextFieldDelegate {
        let sut = CardFieldMaskingFactory()
            .buildMaskingDelegate(for: .cardNumber, listener: listenerMock)
        textField.delegate = sut
        _ = sut.update(maskFormat: inputMaskResolver.panMask(for: cardNumber), using: textField)
        listenerMock.fullReset()
        return sut
    }
}
