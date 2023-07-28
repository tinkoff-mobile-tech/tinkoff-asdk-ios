//
//  ReceiptTests.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 26.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ReceiptTests: BaseTestCase {

    func test_init_with_valid_mandatory_fields() {
        // given
        let validPhone = "+79991459557"
        let validEmail = "some@email.com"

        // when
        let validReceipts = [
            try? setupSut(phone: validPhone, email: validEmail),
            try? setupSut(phone: validPhone, email: nil),
            try? setupSut(phone: nil, email: validEmail),
        ]

        // then
        let validReceiptsBools = validReceipts.map { $0 != nil }
        XCTAssert(validReceiptsBools.allSatisfy { $0 == true })
    }

    func test_init_with_invalid_mandatory_fields() {
        // given
        let invalidPhone = "   "
        let invalidEmail = "        "

        // when
        let ivalidReceipts = [
            try? setupSut(phone: nil, email: nil),
            try? setupSut(phone: invalidPhone, email: nil),
            try? setupSut(phone: nil, email: invalidEmail),
            try? setupSut(phone: "", email: ""),
        ]

        // then
        let invalidReceiptsBools = ivalidReceipts.map { $0 == nil }
        XCTAssert(invalidReceiptsBools.allSatisfy { $0 == true })
    }

    func test_init_with_invalid_email() {
        // given
        let invalidEmails = ["EMAIL", "1 2 3", " ", "myEmail@.", "@.ru"]

        // when
        let errors: [ASDKCoreError] = invalidEmails.compactMap { email in
            do { _ = try setupSut(phone: nil, email: email) }
            catch {
                if let error = error as? ASDKCoreError { return error }
            }

            return nil
        }

        // then
        XCTAssertEqual(invalidEmails.count, errors.count)
        XCTAssert(errors.allSatisfy { $0 == .invalidEmail })
    }
}

extension ReceiptTests {

    private func setupSut(phone: String?, email: String?) throws -> Receipt {
        try Receipt(
            shopCode: nil,
            email: email,
            taxation: nil,
            phone: phone,
            items: nil,
            agentData: nil,
            supplierInfo: nil,
            customer: nil,
            customerInn: nil
        )
    }
}
