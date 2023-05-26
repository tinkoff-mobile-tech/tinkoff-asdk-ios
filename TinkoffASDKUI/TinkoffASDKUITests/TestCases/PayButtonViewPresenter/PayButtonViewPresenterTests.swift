//
//  PayButtonViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PayButtonViewPresenterTests: BaseTestCase {

    var sut: PayButtonViewPresenter!

    // MARK: Mocks

    var viewMock: PayButtonViewInputMock!
    var outputMock: PayButtonViewPresenterOutputMock!
    var moneyFormatterMock: MoneyFormatterMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(with: .pay)
    }

    override func tearDown() {
        viewMock = nil
        outputMock = nil
        moneyFormatterMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_startLoading() {
        // when
        sut.startLoading()

        // then
        XCTAssertEqual(viewMock.startLoadingCallsCount, 1)
    }

    func test_stopLoading() {
        // when
        sut.stopLoading()

        // then
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }
}

// MARK: - Private methods

extension PayButtonViewPresenterTests {
    private func setupSut(with state: PayButtonViewPresentationState) {
        viewMock = PayButtonViewInputMock()
        outputMock = PayButtonViewPresenterOutputMock()
        moneyFormatterMock = MoneyFormatterMock()

        sut = PayButtonViewPresenter(
            presentationState: state,
            moneyFormatter: moneyFormatterMock,
            output: outputMock
        )
        sut.view = viewMock

        viewMock.fullReset()
    }
}
