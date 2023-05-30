//
//  SavedCardViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewPresenterTests: BaseTestCase {

    var sut: SavedCardViewPresenter!

    // MARK: Mocks

    var viewMock: SavedCardViewInputMock!
    var validatorMock: CardRequisitesValidatorMock!
    var paymentSystemResolverMock: PaymentSystemResolverMock!
    var bankResolverMock: BankResolverMock!
    var outputMock: SavedCardViewPresenterOutputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_activateCVCField() {
        // when
        sut.activateCVCField()

        // then
        XCTAssertEqual(viewMock.activateCVCFieldCallsCount, 1)
    }
}

// MARK: - Private methods

extension SavedCardViewPresenterTests {
    private func setupSut() {
        viewMock = SavedCardViewInputMock()
        validatorMock = CardRequisitesValidatorMock()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        bankResolverMock = BankResolverMock()
        outputMock = SavedCardViewPresenterOutputMock()

        sut = SavedCardViewPresenter(
            validator: validatorMock,
            paymentSystemResolver: paymentSystemResolverMock,
            bankResolver: bankResolverMock,
            output: outputMock
        )

        sut.view = viewMock
        viewMock.fullReset()
        validatorMock.fullReset()
        paymentSystemResolverMock.fullReset()
        bankResolverMock.fullReset()
    }
}
