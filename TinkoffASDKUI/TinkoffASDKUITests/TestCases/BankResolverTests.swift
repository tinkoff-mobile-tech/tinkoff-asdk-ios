//
//  BankResolverTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.11.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class BankResolverTests: XCTestCase {

    func test_resolve_should_return_noValue_error() throws {
        let sut = getSut()
        let expectedResult = BankResult.incorrectInput(error: .noValue)
        let result = sut.resolve(cardNumber: "")
        XCTAssertEqual(result, expectedResult)
    }

    func test_resolve_should_return_notEnoughData_error() throws {
        let sut = getSut()
        let expectedResult = BankResult.incorrectInput(error: .notEnoughData)
        let result = sut.resolve(cardNumber: "1234")
        XCTAssertEqual(result, expectedResult)
    }

    func test_bank_parsing() throws {
        let banks = Bank.allCases

        for bank in banks {
            switch bank {
            case .sber:
                try resolve_should_return_parsed_sber()
            case .tinkoff:
                try resolve_should_return_parsed_tinkoff()
            case .vtb:
                try resolve_should_return_parsed_vtb()
            case .gazprom:
                try resolve_should_return_parsed_gazprom()
            case .raiffaisen:
                try resolve_should_return_parsed_raifaissen()
            case .alpha:
                try resolve_should_return_parsed_alpha()
            case .other:
                try resolve_should_return_parsed_other()
            }
        }
    }
}

private extension BankResolverTests {

    // MARK: - Sub test functions

    func resolve_should_return_parsed_alpha() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .alpha)

        // when
        let results = Bank.Bin.alpha.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_sber() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .sber)

        // when
        let results = Bank.Bin.sber.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_vtb() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .vtb)

        // when
        let results = Bank.Bin.vtb.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_tinkoff() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .tinkoff)

        // when
        let results = Bank.Bin.tinkoff.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_gazprom() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .gazprom)

        // when
        let results = Bank.Bin.gazprom.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_raifaissen() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .raiffaisen)

        // when
        let results = Bank.Bin.raiffaisen.map { sut.resolve(cardNumber: $0) }
        let allResolvedBanksAreAlpha = results.allSatisfy { resolvedBank in
            resolvedBank == expectedResult
        }

        // then
        XCTAssertTrue(allResolvedBanksAreAlpha)
    }

    func resolve_should_return_parsed_other() throws {
        // given
        let sut = getSut()
        let expectedResult = BankResult.parsed(bank: .other)

        // when
        let result = sut.resolve(cardNumber: "112414")

        // then
        XCTAssertEqual(result, expectedResult)
    }

    // MARK: - Helpers

    func getSut() -> IBankResolver {
        BankResolver()
    }
}
