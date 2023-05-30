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

final class BankResolverTests: BaseTestCase {

    func test_resolve_should_return_noValue_error() throws {
        allureId(2416099, "BankResolver возвращает ошибку noValue для пустой строки")

        let sut = getSut()
        let expectedResult = BankResult.incorrectInput(error: .noValue)
        let result = sut.resolve(cardNumber: "")
        XCTAssertEqual(result, expectedResult)
    }

    func test_resolve_should_return_notEnoughData_error() throws {
        allureId(2416094, "BankResolver возвращает ошибку notEnoughData для BIN < 6 символов")

        let sut = getSut()
        let expectedResult = BankResult.incorrectInput(error: .notEnoughData)
        let result = sut.resolve(cardNumber: "1234")
        XCTAssertEqual(result, expectedResult)
    }

    func test_resolve_should_return_noValue_error_when_value_is_nil() {
        allureId(2416116, "BankResolver возвращает ошибку noValue для nil")

        let sut = getSut()
        let expectedResult = BankResult.incorrectInput(error: .noValue)
        let result = sut.resolve(cardNumber: nil)
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
        allureId(2415829, "BankResolver определяет BIN для Альфа")

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
        allureId(2415806, "BankResolver определяет BIN для Сбер")

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
        allureId(2415839, "BankResolver определяет BIN для ВТБ")

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
        allureId(2415809, "BankResolver определяет BIN для Тинькофф")

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
        allureId(2415807, "BankResolver определяет BIN для Газпром")

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
        allureId(2415815, "BankResolver определяет BIN для Райфайзен")

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
        allureId(2415840, "BankResolver определяет BIN для другого банка")

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
