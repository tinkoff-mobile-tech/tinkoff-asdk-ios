//
//  TinkoffPayAppCheckerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 21.06.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TinkoffPayAppCheckerTests: BaseTestCase {

    var sut: TinkoffPayAppChecker!

    // Mocks

    var appCheckerMock: AppCheckerMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        appCheckerMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_isTinkoffPayAppInstalled_when_installed() {
        // given
        let scheme = "tinkoffbank"
        appCheckerMock.checkApplicationReturnValue = .installed

        // when
        let isInstalled = sut.isTinkoffPayAppInstalled()

        // then
        XCTAssertEqual(appCheckerMock.checkApplicationCallsCount, 1)
        XCTAssertEqual(appCheckerMock.checkApplicationReceivedArguments, scheme)
        XCTAssertTrue(isInstalled)
    }

    func test_isTinkoffPayAppInstalled_when_notInstalled() {
        // given
        let scheme = "tinkoffbank"
        appCheckerMock.checkApplicationReturnValue = .notInstalled

        // when
        let isInstalled = sut.isTinkoffPayAppInstalled()

        // then
        XCTAssertEqual(appCheckerMock.checkApplicationCallsCount, 1)
        XCTAssertEqual(appCheckerMock.checkApplicationReceivedArguments, scheme)
        XCTAssertFalse(isInstalled)
    }
}

// MARK: - Private methods

extension TinkoffPayAppCheckerTests {
    private func setupSut() {
        appCheckerMock = AppCheckerMock()
        sut = TinkoffPayAppChecker(appChecker: appCheckerMock)
    }
}
