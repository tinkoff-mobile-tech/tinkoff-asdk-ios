//
//  CardDataFormatterTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 18.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class CardDataFormatterTests: XCTestCase {
    // MARK: Properties

    private var sut: CardDataFormatter!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        sut = CardDataFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatFormatterFormatsCardDataWithCardID_whenCVVIsNotNil() {
        // when
        let data = sut.formatCardData(cardId: .cardID, cvv: .cvv)

        // then
        XCTAssertEqual(data, "CVV=\(String.cvv);CardId=\(String.cardID)")
    }

    func test_thatFormatterFormatsCardDataWithCardID_whenCVVIsNil() {
        // when
        let data = sut.formatCardData(cardId: .cardID, cvv: nil)

        // then
        XCTAssertEqual(data, "CardId=\(String.cardID)")
    }

    func test_thatFormatterFormatsCardDataWithCardNumber() {
        // when
        let data = sut.formatCardData(cardNumber: .cardNumber, expDate: .expDate, cvv: .cvv)

        // then
        XCTAssertEqual(data, "PAN=\(String.cardNumber);ExpDate=\(String.expDate);CVV=\(String.cvv)")
    }
}

// MARK: Constants

private extension String {
    static let cardID = "card_id"
    static let cvv = "123"
    static let cardNumber = "1234 5678 9123 4567"
    static let expDate = "11/2023"
}
