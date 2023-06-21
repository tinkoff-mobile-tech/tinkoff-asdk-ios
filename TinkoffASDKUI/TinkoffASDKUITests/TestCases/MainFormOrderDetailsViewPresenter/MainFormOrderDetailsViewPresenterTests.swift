//
//  MainFormOrderDetailsViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MainFormOrderDetailsViewPresenterTests: BaseTestCase {

    var sut: MainFormOrderDetailsViewPresenter!

    // MARK: Mocks

    var viewMock: MainFormOrderDetailsViewInputMock!
    var moneyFormatterMock: MoneyFormatterMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        moneyFormatterMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_setupView() {
        // given
        let amountDescription = Loc.CommonSheet.PaymentForm.toPayTitle
        let amount: Int64 = 250
        let orderDescription = "any description"

        setupSut(amount: amount, orderDescription: orderDescription)

        let expectedAmount = Int(250)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setAmountDescriptionCallsCount, 1)
        XCTAssertEqual(viewMock.setAmountDescriptionReceivedArguments, amountDescription)
        XCTAssertEqual(viewMock.setAmountCallsCount, 1)
        XCTAssertEqual(moneyFormatterMock.formatAmountCallsCount, 1)
        XCTAssertEqual(moneyFormatterMock.formatAmountReceivedArguments, expectedAmount)
        XCTAssertEqual(viewMock.setOrderDescriptionCallsCount, 1)
        XCTAssertEqual(viewMock.setOrderDescriptionReceivedArguments, orderDescription)
    }

    func test_copy() {
        // when
        let copySut = sut.copy() as? MainFormOrderDetailsViewPresenter

        // then
        XCTAssertEqual(copySut, sut)
    }
}

// MARK: - Private methods

extension MainFormOrderDetailsViewPresenterTests {
    private func setupSut(amount: Int64 = 100, orderDescription: String? = nil) {
        viewMock = MainFormOrderDetailsViewInputMock()
        moneyFormatterMock = MoneyFormatterMock()

        sut = MainFormOrderDetailsViewPresenter(
            moneyFormatter: moneyFormatterMock,
            amount: amount,
            orderDescription: orderDescription
        )
        sut.view = viewMock

        viewMock.fullReset()
        moneyFormatterMock.fullReset()
    }
}
