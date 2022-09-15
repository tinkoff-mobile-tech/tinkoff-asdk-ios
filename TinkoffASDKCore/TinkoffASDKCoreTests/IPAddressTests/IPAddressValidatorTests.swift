//
//  IPAddressValidatorTests.swift
//  Pods
//
//  Created by grisha on 09.12.2020.
//

@testable import TinkoffASDKCore
import XCTest

class IPAddressValidatorTests: XCTestCase {
    private let validator = IPAddressValidator()
    
    // MARK: IPv4
    
    func testIPv4AddressValidationOne() {
        let address = "192.168.0.1"
        XCTAssertTrue(validator.validateIPAddress(address, type: .v4))
    }
    
    // MARK: IPv6
    
    func testIPv6AddressValidationSuccessOne() {
        let address = "fe80:0000:0000:0000:aede:48ff:fe00:1122"
        XCTAssertTrue(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationSuccessTwo() {
        let address = "fe80::aede:48ff:fe00:1122"
        XCTAssertTrue(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationSuccessThree() {
        let address = "fe80::0e:48ff:fe00:1122"
        XCTAssertTrue(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedOne() {
        let address = "fe800000:0000:0000:aede:48ff:fe00:1122"
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedTwo() {
        let address = "fe80::0000:0000:0000:aede:48ff:fe00:1122"
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedThree() {
        let address = "fe80:0000:0000:aede:48ff:fe00:1122"
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedFour() {
        let address = ""
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedFive() {
        let address = "192.168.0.1"
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
    
    func testIPv6AddressValidationFailedSix() {
        let address = "ge80:0000:0000:0000:aede:48ff:fe00:1122"
        XCTAssertFalse(validator.validateIPAddress(address, type: .v6))
    }
}
