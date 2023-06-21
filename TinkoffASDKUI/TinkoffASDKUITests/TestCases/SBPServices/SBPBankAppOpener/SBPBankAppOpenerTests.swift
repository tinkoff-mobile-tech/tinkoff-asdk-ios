//
//  SBPBankAppOpenerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBankAppOpenerTests: BaseTestCase {

    var sut: SBPBankAppOpener!

    // MARK: Mocks

    var applicationMock: UIApplicationMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        applicationMock = UIApplicationMock()
        sut = SBPBankAppOpener(application: applicationMock)
    }

    override func tearDown() {
        applicationMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_openBankApp_successOpen() throws {
        // given
        let someUrlOptional = URL(string: "https://www.google.com")
        let someUrl = try XCTUnwrap(someUrlOptional)
        let bank = SBPBank.any
        applicationMock.openCompletionClosureInput = true

        var isOpenSuccess = false
        let openCompletion: SBPBankAppCheckerOpenBankAppCompletion = { isOpen in
            isOpenSuccess = isOpen
        }

        // when
        sut.openBankApp(url: someUrl, bank, completion: openCompletion)

        // then
        XCTAssertEqual(applicationMock.openCallsCount, 1)
        XCTAssertTrue(isOpenSuccess)
    }

    // FIXME: Починить тест ибо в Xcode 15.0 ломается (ссылку не может сформировать)
    func test_openBankApp_failureOpen_when_wrongUrl() throws {
//        // given
//        let someUrlOptional = URL(string: "http://example.com:-80/")
//        let someUrl = try XCTUnwrap(someUrlOptional)
//        let bank = SBPBank.any
//        applicationMock.openCompletionClosureInput = true
//
//        var isOpenSuccess = false
//        let openCompletion: SBPBankAppCheckerOpenBankAppCompletion = { isOpen in
//            isOpenSuccess = isOpen
//        }
//
//        // when
//        sut.openBankApp(url: someUrl, bank, completion: openCompletion)
//
//        // then
//        XCTAssertEqual(applicationMock.openCallsCount, 0)
//        XCTAssertFalse(isOpenSuccess)
    }
}
