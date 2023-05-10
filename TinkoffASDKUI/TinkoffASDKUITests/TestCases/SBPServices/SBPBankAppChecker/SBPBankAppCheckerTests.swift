//
//  SBPBankAppCheckerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBankAppCheckerTests: BaseTestCase {

    var sut: SBPBankAppChecker!

    // MARK: Mocks

    var appCheckerMock: AppCheckerMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        appCheckerMock = AppCheckerMock()
        sut = SBPBankAppChecker(appChecker: appCheckerMock)
    }

    override func tearDown() {
        appCheckerMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_bankAppsPreferredByMerchant_when_installed() {
        // given
        let loadedBanks = [SBPBank.some(1), SBPBank.some(2), SBPBank.some(3)]
        let banksSchemes = loadedBanks.map { $0.schema }
        appCheckerMock.checkApplicationReturnValue = .installed

        // when
        let prefferedBanks = sut.bankAppsPreferredByMerchant(from: loadedBanks)

        // then
        XCTAssertEqual(appCheckerMock.checkApplicationCallsCount, loadedBanks.count)
        XCTAssertEqual(prefferedBanks.count, loadedBanks.count)
        XCTAssertEqual(appCheckerMock.checkApplicationReceivedInvocations, banksSchemes)
    }

    func test_bankAppsPreferredByMerchant_when_notInstalled() {
        // given
        let loadedBanks = [SBPBank.some(1), SBPBank.some(2), SBPBank.some(3)]
        let banksSchemes = loadedBanks.map { $0.schema }
        appCheckerMock.checkApplicationReturnValue = .notInstalled

        // when
        let prefferedBanks = sut.bankAppsPreferredByMerchant(from: loadedBanks)

        // then
        XCTAssertEqual(appCheckerMock.checkApplicationCallsCount, loadedBanks.count)
        XCTAssertEqual(prefferedBanks.count, 0)
        XCTAssertEqual(appCheckerMock.checkApplicationReceivedInvocations, banksSchemes)
    }

    func test_bankAppsPreferredByMerchant_when_ambiguous() {
        // given
        let loadedBanks = [SBPBank.some(1), SBPBank.some(2), SBPBank.some(3)]
        let banksSchemes = loadedBanks.map { $0.schema }
        appCheckerMock.checkApplicationReturnValue = .ambiguous

        // when
        let prefferedBanks = sut.bankAppsPreferredByMerchant(from: loadedBanks)

        // then
        XCTAssertEqual(appCheckerMock.checkApplicationCallsCount, loadedBanks.count)
        XCTAssertEqual(prefferedBanks.count, 0)
        XCTAssertEqual(appCheckerMock.checkApplicationReceivedInvocations, banksSchemes)
    }
}
