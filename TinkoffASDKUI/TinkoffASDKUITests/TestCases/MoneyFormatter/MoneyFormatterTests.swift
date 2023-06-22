//
//  MoneyFormatterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 22.06.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MoneyFormatterTests: BaseTestCase {

    var sut: MoneyFormatter!

    // MARK: Mocks

    // MARK: Setup

    override func setUp() {
        super.setUp()

        sut = MoneyFormatter()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_formatAmount_4560() {
        // given
        let amount = 4560

        // when
        let formattedString = sut.formatAmount(amount)

        // then
        XCTAssertEqual(formattedString, "45,6 ₽")
    }

    func test_formatAmount_0() {
        // given
        let amount = 0

        // when
        let formattedString = sut.formatAmount(amount)

        // then
        XCTAssertEqual(formattedString, "0 ₽")
    }

    func test_formatAmount_minus_123143241234() {
        // given
        let amount = -123143241234

        // when
        let formattedString = sut.formatAmount(amount)

        // then
        XCTAssertEqual(formattedString, "-1 231 432 412,34 ₽")
    }
}
