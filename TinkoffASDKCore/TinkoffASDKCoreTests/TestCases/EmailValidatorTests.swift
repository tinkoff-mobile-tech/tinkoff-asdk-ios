//
//  EmailValidatorTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 27.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class EmailValidatorTests: BaseTestCase {

    var sut: EmailValidator!

    override func setUp() {
        sut = EmailValidator()
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_isValid_for_invalid_emails() {
        // given
        let invalidEmail = [
            "@com.ru",
            "com.ru",
            "nice_mail@gmail.",
            "chatgptinfo.box",
            nil,
            "",
            "   ",
            "123",
        ]

        // when
        let results = invalidEmail.map { sut.isValid($0) }

        // then
        XCTAssert(results.allSatisfy { $0 == false })
    }

    func test_isValid_for_valid_emails() {
        // given
        let validEmail = [
            "email@com.ru",
            "e@com.ru",
            "nice_mail@gmail.com",
            "chatgpt@info.box",
        ]

        // when
        let results = validEmail.map { sut.isValid($0) }

        // then
        XCTAssert(results.allSatisfy { $0 == true })
    }
}
