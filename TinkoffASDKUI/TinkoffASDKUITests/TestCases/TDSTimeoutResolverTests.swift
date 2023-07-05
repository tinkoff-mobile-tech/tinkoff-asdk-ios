//
//  TDSTimeoutResolverTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 05.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class TDSTimeoutResolverTests: XCTestCase {
    // MARK: Properties

    private var sut: TDSTimeoutResolver!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        sut = TDSTimeoutResolver()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatTimeoutResolverHasCorrectMaipValue() {
        // when
        let value = sut.mapiValue

        // then
        XCTAssertEqual(value, "05")
    }

    func test_thatTimeoutResolverHasCorrectChallengeValue() {
        // when
        let value = sut.challengeValue

        // then
        XCTAssertEqual(value, 5)
    }
}
