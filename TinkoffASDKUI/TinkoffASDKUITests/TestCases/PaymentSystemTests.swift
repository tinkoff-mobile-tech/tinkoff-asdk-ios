//
//  PaymentSystemTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.11.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class PaymentSystemTests: XCTestCase {

    func test_paymentSystem_regexPatterns() throws {
        // given

        let paymentSystems = PaymentSystem.allCases

        // when

        for paymentSystem in paymentSystems {
            switch paymentSystem {
            case .visa:
                XCTAssertEqual(paymentSystem.regexPattern.rawValue, PaymentSystem.Pattern.visa.rawValue)
            case .masterCard:
                XCTAssertEqual(paymentSystem.regexPattern.rawValue, PaymentSystem.Pattern.masterCard.rawValue)
            case .maestro:
                XCTAssertEqual(paymentSystem.regexPattern.rawValue, PaymentSystem.Pattern.maestro.rawValue)
            case .mir:
                XCTAssertEqual(paymentSystem.regexPattern.rawValue, PaymentSystem.Pattern.mir.rawValue)
            case .unionPay:
                XCTAssertEqual(paymentSystem.regexPattern.rawValue, PaymentSystem.Pattern.unionPay.rawValue)
            }
        }
    }

    func test_paymentSystem_icons() throws {
        // given

        let paymentSystems = PaymentSystem.allCases

        // when

        for paymentSystem in paymentSystems {
            switch paymentSystem {
            case .visa:
                XCTAssertEqual(paymentSystem.icon, .visa)
            case .masterCard:
                XCTAssertEqual(paymentSystem.icon, .masterCard)
            case .maestro:
                XCTAssertEqual(paymentSystem.icon, .maestro)
            case .mir:
                XCTAssertEqual(paymentSystem.icon, .mir)
            case .unionPay:
                XCTAssertEqual(paymentSystem.icon, .uninonPay)
            }
        }
    }
}
