//
//  FinishResponseTests.swift
//  TinkoffASDKCoreTests
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import TinkoffASDKCore
import XCTest

class FinishResponseTests: XCTestCase {
    private var sdk: AcquiringSdk!

    override func setUp() {
        let credential = AcquiringSdkCredential(terminalKey: StageTestData.terminalKey,
                                                publicKey: StageTestData.testPublicKey)
        
        let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credential)
        acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

        if let asdk = try? AcquiringSdk(configuration: acquiringSDKConfiguration) {
            sdk = asdk
        }

        XCTAssertNotNil(sdk)
    }

    /**
     * Проверка статуса `Result.Error`
     */
    func test_FinishResponseError() {
        let errorCode: Int = 243
        let message: String = "Ошибка шифрования карточных данных."
        //
        let jsonResponseData =
            """
            {
            "Success": false,
            "ErrorCode": "\(errorCode)",
            "Message": "\(message)"
            }
            """

        let responseData = Data(jsonResponseData.utf8)
        if let response = try? JSONDecoder().decode(PaymentFinishResponse.self, from: responseData) {
            XCTAssertTrue(response.errorCode == errorCode, "errorCode = '\(errorCode)'")
            XCTAssertTrue(response.errorMessage == message, "errorMessage = '\(message)'")
            XCTAssertTrue(response.errorDetails == nil, "errorDetails = 'nil'")
            XCTAssertTrue(response.paymentStatus == .unknown)
            XCTAssertTrue({ if case .unknown = response.responseStatus { return true }; return false }())

        } else {
            XCTAssert(false, "error response data")
        }
    }

    /**
     * Проверка стартуса `Result.Success`
     */
    func test_FinishResponseSuccess() {
        let errorCode: Int = 0
        let terminalKey: String = ASDKStageTestData.terminalKey
        let amount: Int64 = 20000
        let orderId: Int64 = 8_221_860
        let paymentId: Int64 = 142_639_745
        let status = "NEW"
        //
        let jsonResponseData =
            """
            {
            "Success": true,
            "ErrorCode": "\(errorCode)",
            "Amount": \(amount),
            "OrderId": \(orderId),
            "PaymentId": \(paymentId),
            "Status": "\(status)",
            "TerminalKey": "\(terminalKey)"
            }
            """

        let responseData = Data(jsonResponseData.utf8)
        if let response = try? JSONDecoder().decode(PaymentFinishResponse.self, from: responseData) {
            XCTAssertTrue(response.errorCode == errorCode, "errorCode = '\(errorCode)'")
            XCTAssertTrue(response.errorMessage == nil, "errorMessage = 'nil'")
            XCTAssertTrue(response.terminalKey == terminalKey, "terminalKey = '\(terminalKey)'")
            XCTAssertNotNil(response.terminalKey)
            XCTAssertTrue(response.paymentStatus == .new)

            switch response.responseStatus {
            case let .done(status):
                XCTAssertTrue(status.amount.int64Value == Int64(amount / 100))
                XCTAssertTrue(status.orderId == String(orderId))
                XCTAssertTrue(status.paymentId == paymentId)
            default:
                XCTAssert(false)
            }
        } else {
            XCTAssert(false, "error response data")
        }
    }

    /**
     * Проверка статуса Result.Success - нужно подтверждение платежа 3DS
     */
    func test_FinishResponseNeed3DSConfirmation() {
        let errorCode: Int = 0
        let terminalKey: String = ASDKStageTestData.terminalKey
        let amount: Int64 = 2332
        let orderId: Int64 = 87_654_321
        let paymentId: Int64 = 12_345_678
        let status = PaymentStatus.checking3ds.rawValue // "3DS_CHECKING"
        let acsUrl = "https://tinkoff.ru/v2/FinishAuthorize"
        let paReq = "qwertyuiop123"
        let md = "asdfghjkl123"
        //
        let jsonResponseData =
            """
            {
            "Success": true,
            "ErrorCode": "\(errorCode)",
            "Amount": \(amount),
            "OrderId": \(orderId),
            "PaymentId": \(paymentId),
            "Status": "\(status)",
            "TerminalKey": "\(terminalKey)",
            "ACSUrl": "\(acsUrl)",
            "PaReq": "\(paReq)",
            "MD": "\(md)"
            }
            """

        let responseData = Data(jsonResponseData.utf8)
        if let response = try? JSONDecoder().decode(PaymentFinishResponse.self, from: responseData) {
            XCTAssertTrue(response.errorCode == errorCode, "errorCode = '\(errorCode)'")
            XCTAssertTrue(response.errorMessage == nil, "errorMessage = 'nil'")
            XCTAssertTrue(response.terminalKey == terminalKey, "terminalKey = '\(terminalKey)'")
            XCTAssertNotNil(response.terminalKey)
            XCTAssertTrue(response.paymentStatus == .checking3ds)

            switch response.responseStatus {
            case let .needConfirmation3DS(confirmation):
                XCTAssertTrue(confirmation.acsUrl == acsUrl)
                XCTAssertTrue(confirmation.pareq == paReq)
                XCTAssertTrue(confirmation.md == md)
            default:
                XCTAssert(false)
            }
        } else {
            XCTAssert(false, "error response data")
        }
    }
}

struct ASDKStageTestData {
    static let terminalKey = "324324"
    static let customerKey = "234234"
}
