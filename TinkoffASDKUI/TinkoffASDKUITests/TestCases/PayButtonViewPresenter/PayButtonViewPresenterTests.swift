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

    func test_setEnabled_true() {
        // when
        sut.set(enabled: true)

        // then
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, true)
    }

    func test_setEnabled_false() {
        // when
        sut.set(enabled: false)

        // then
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, false)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, true)
    }

    func test_payButton_Tapped() {
        // when
        sut.payButtonTapped()

        // then
        XCTAssertEqual(outputMock.payButtonViewTappedCallsCount, 1)
    }

    func test_setupView_when_presentationState_pay() {
        // given
        let title = Loc.CommonSheet.PaymentWaiting.primaryButton
        setupSut(with: .pay)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setConfigurationReceivedArguments?.title, title)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }

    func test_setupView_when_presentationState_payByCard() {
        // given
        let title = Loc.CommonSheet.PaymentForm.byCardPrimaryButton
        setupSut(with: .payByCard)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setConfigurationReceivedArguments?.title, title)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }

    func test_setupView_when_presentationState_payWithAmount_notLoading() {
        // given
        let amount = 123
        setupSut(with: .payWithAmount(amount: amount))
        sut.startLoading()
        viewMock.startLoadingCallsCount = 0

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.startLoadingCallsCount, 1)
    }

    func test_setupView_when_presentationState_tinkoffPay() {
        // given
        setupSut(with: .tinkoffPay)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }

    func test_setupView_when_presentationState_sbp() {
        // given
        setupSut(with: .sbp)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }

    func test_set_newPresentationState_sbp() {
        // when
        sut.presentationState = .sbp

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 1)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.enabled, true)
        XCTAssertEqual(viewMock.setEnabledAnimatedReceivedArguments?.animated, false)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 1)
    }

    func test_set_samePresentationState_pay() {
        // when
        sut.presentationState = .pay

        // then
        XCTAssertEqual(viewMock.setConfigurationCallsCount, 0)
        XCTAssertEqual(viewMock.setEnabledAnimatedCallsCount, 0)
        XCTAssertEqual(viewMock.stopLoadingCallsCount, 0)
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
