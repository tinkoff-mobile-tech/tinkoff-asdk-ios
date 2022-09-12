//
//  CoreTests.swift
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

class CoreTests: XCTestCase {
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
     * Формирование секретного ключа - `Token`Используется для подписи запросов/ответов.
     */
    func test_createToken() {
        /// параметры для формирования токены

        let jsonPaymentData =
            """
            {
            "Amount": 20000,
            "OrderId": 7058307,
            "CustomerKey": \"\(StageTestData.customerKey)\"
            }
            """

        let validToken = "0bc50ed09112c7cd380b4651010e25d98cad9b5a9b7d14c09292c01d401ce400"
        let paymentData = Data(jsonPaymentData.utf8)
        if let requestData = try? JSONDecoder().decode(PaymentInitData.self, from: paymentData) {
            let request = PaymentInitRequest(data: requestData)

            var tokenParams: JSONObject = [:]
            /// Добаялем обязательные параметры для формирования токена
            tokenParams.updateValue(StageTestData.terminalKey, forKey: "TerminalKey")
            tokenParams.updateValue(StageTestData.terminalPassword, forKey: "Password")

            tokenParams.merge(request.tokenParams()) { (_, new) -> JSONValue in new }

            let tokenSring: String = tokenParams.sorted(by: { (arg1, arg2) -> Bool in
                arg1.key < arg2.key
            }).map { (item) -> String? in
                String(describing: item.value)
            }.compactMap { $0 }.joined()

            let token = tokenSring.sha256()
            XCTAssertEqual(validToken, token, "Токен сформирован не верно")

        } else {
            XCTAssert(false, "Не удалось сформировать платежные данные")
        }
    }
}
