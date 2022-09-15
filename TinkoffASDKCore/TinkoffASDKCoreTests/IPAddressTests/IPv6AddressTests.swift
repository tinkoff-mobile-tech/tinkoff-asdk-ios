//
//  IPv6AddressTesst.swift
//  ASDKSample
//
//  Created by grisha on 09.12.2020.
//  Copyright © 2020 Tinkoff. All rights reserved.
//

@testable import TinkoffASDKCore
import XCTest

class IPv6AddressTest: XCTestCase {
    
    func testIPv6AddressSuccessInitOne() {
        let ipv6String = "fe80::aede:48ff:fe00:1122"
        let ipv6Address = IPv6Address(ipv6String)
        
        XCTAssertNotNil(ipv6Address)
    }
    
    func testIPv6AddressSuccessInitTwo() {
        let ipv6String = "fe80:0000:0000:0000:aede:48ff:fe00:1122"
        let ipv6Address = IPv6Address(ipv6String)
        
        XCTAssertNotNil(ipv6Address)
    }
    
    func testIPv6AddressSuccessInitThree() {
        let ipv6String = "fe80::0:0f:fe00:1122"
        let ipv6Address = IPv6Address(ipv6String)
        
        XCTAssertNotNil(ipv6Address)
    }
    
    func testIPv6AddressInitFailedOne() {
        let ipv4String = "192.168.0.1"
        let ipv6Address = IPv6Address(ipv4String)
        
        XCTAssertNil(ipv6Address)
    }
    
    func testIPv6AddressInitFailedTwo() {
        let notIPAddressString = "ads"
        let ipv6Address = IPv6Address(notIPAddressString)
        
        XCTAssertNil(ipv6Address)
    }
    
    func testIPv6AddressInitFailedThree() {
        let wrongIPv6String = "fe80:aede:48ff:fe00:1122"
        let ipv6Address = IPv6Address(wrongIPv6String)
        
        XCTAssertNil(ipv6Address)
    }
    
    func testIPv6AddressInitFailedFour() {
        let wrongIPv6String = "fe80::aede::48ff:fe00:1122"
        let ipv6Address = IPv6Address(wrongIPv6String)
        
        XCTAssertNil(ipv6Address)
    }
    
    func testIPv6AddressInitFailedFive() {
        let wrongIPv6String = "fe80:0000:0000:z292:aede:48ff:fe00:1122"
        let ipv6Address = IPv6Address(wrongIPv6String)
        
        XCTAssertNil(ipv6Address)
    }
    
    func testIPv6CorrectStringValue() {
        let ipv6String = "fe80::aede:48ff:fe00:1122"
        guard let ipv6Address = IPv6Address(ipv6String) else {
            assertionFailure("must init success with: \(ipv6String)")
            return
        }
        
        assert(ipv6Address.stringValue == ipv6String,
               "ipv6Address's string value must be equal to ipv6String")
    }
    
    func testIfIPv6CorrectFullStringValueOne() {
        let ipv6String = "fe80::aede:48ff:fe00:1122"
        let ipv6FullString = "fe80:0000:0000:0000:aede:48ff:fe00:1122"
        guard let ipv6Address = IPv6Address(ipv6String) else {
            assertionFailure("must init success with: \(ipv6String)")
            return
        }
        
        assert(ipv6Address.fullStringValue == ipv6FullString,
               "ipv6Address's string value must be equal to ipv6String")
    }
    
    func testIfIPv6CorrectFullStringValueTwo() {
        let ipv6String = "fe80::0:0f:fe00:1122"
        let ipv6FullString = "fe80:0000:0000:0000:0000:000f:fe00:1122"
        guard let ipv6Address = IPv6Address(ipv6String) else {
            assertionFailure("must init success with: \(ipv6String)")
            return
        }
        
        assert(ipv6Address.fullStringValue == ipv6FullString,
               "ipv6Address's string value must be equal to ipv6String")
    }
}
