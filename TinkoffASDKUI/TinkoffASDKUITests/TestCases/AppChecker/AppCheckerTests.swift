//
//  AppCheckerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 21.06.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AppCheckerTests: BaseTestCase {

    var sut: AppChecker!

    // Mocks

    var applicationMock: UIApplicationMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        applicationMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_checkApplication_when_containsInQueriesSchemes() {
        // given
        let scheme = "bank100000000001"
        setupSut(queriesSchemes: [scheme])
        applicationMock.canOpenURLReturnValue = true

        // when
        let result = sut.checkApplication(withScheme: scheme)

        // then
        XCTAssertEqual(applicationMock.canOpenURLCallsCount, 1)
        XCTAssertEqual(result, .installed)
    }

    func test_checkApplication_when_containsInQueriesSchemes_but_cant_open() {
        // given
        let scheme = "bank100000000001"
        setupSut(queriesSchemes: [scheme])
        applicationMock.canOpenURLReturnValue = false

        // when
        let result = sut.checkApplication(withScheme: scheme)

        // then
        XCTAssertEqual(applicationMock.canOpenURLCallsCount, 1)
        XCTAssertEqual(result, .notInstalled)
    }

    func test_checkApplication_when_notContainsInQueriesSchemes() {
        // given
        let scheme = "someSome"
        applicationMock.canOpenURLReturnValue = true

        // when
        let result = sut.checkApplication(withScheme: scheme)

        // then
        XCTAssertEqual(applicationMock.canOpenURLCallsCount, 0)
        XCTAssertEqual(result, .ambiguous)
    }

    func test_checkApplication_when_containsInQueriesSchemes_but_wrongUrl() {
        // given
        let scheme = "!@£a"
        setupSut(queriesSchemes: [scheme])
        applicationMock.canOpenURLReturnValue = true

        // when
        let result = sut.checkApplication(withScheme: scheme)

        // then
        XCTAssertEqual(applicationMock.canOpenURLCallsCount, 0)
        XCTAssertEqual(result, .notInstalled)
    }
}

// MARK: - Private methods

extension AppCheckerTests {
    private func setupSut(queriesSchemes: Set<String>? = nil) {
        applicationMock = UIApplicationMock()
        if let queriesSchemes = queriesSchemes {
            sut = AppChecker(application: applicationMock, queriesSchemes: queriesSchemes)
        } else {
            sut = AppChecker(application: applicationMock)
        }
    }
}
