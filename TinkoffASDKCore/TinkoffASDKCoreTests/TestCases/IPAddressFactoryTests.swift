//
//  IPAddressFactoryTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 20.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class IPAddressFactoryTests: XCTestCase {
    // MARK: Properties

    private var sut: IPAddressFactory!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        sut = IPAddressFactory()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatFactoryResolvesIPv4() {
        // when
        let ipAddress = sut.ipAddress(with: .ipv4)

        // then
        XCTAssertEqual(ipAddress?.stringValue, .ipv4)
        XCTAssertEqual(ipAddress?.fullStringValue, .ipv4)
    }

    func test_thatFactoryResolvesIPv6() {
        // when
        let ipAddress = sut.ipAddress(with: .ipv6)

        // then
        XCTAssertEqual(ipAddress?.stringValue, .ipv6)
        XCTAssertEqual(ipAddress?.fullStringValue, .ipv6)
    }
}

// MARK: - Constants

private extension String {
    static let ipv4 = "192.0.2.146"
    static let ipv6 = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
}
