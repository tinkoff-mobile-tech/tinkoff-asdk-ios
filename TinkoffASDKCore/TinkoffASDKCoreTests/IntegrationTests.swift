//
//  IntegrationTests.swift
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

class IntegrationTests: XCTestCase {
    private let serverTimeout: TimeInterval = 30

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
     * Создание запроса и ожидание ответа от сервера.
     * Запрос ждем 30 секунд.
     * Тест считается удачным если в течении этого времени сервер обработает запрос и ответит данными в нужном формате.
     */
    func test_InitRequest() {
        let completedExpectation = expectation(description: "Completed")

        let jsonPaymentData =
            """
            {
            "Amount": 20000,
            "OrderId": \(arc4random()),
            "CustomerKey": \"\(ASDKStageTestData.customerKey)\",
            "Receipt": {
            	"Email": "a@test.ru",
            	"Items": [
            		{
            		"Amount": 20000,
            		"Name": "123",
            		"Price": 20000,
            		"Quantity": 1,
            		"Tax": "vat10"
            		}
            	],
            	"Taxation": "osn"
            	}
            }
            """

        var requestResponse: PaymentInitResponse?
        var requestError: Error?
        let data = Data(jsonPaymentData.utf8)

        guard let paymentData = try? JSONDecoder().decode(PaymentInitData.self, from: data) else {
            XCTAssert(true, "не удалось создать данные для платежа")
            return
        }

        _ = sdk?.paymentInit(data: paymentData, completionHandler: { response in
            switch response {
            case let .failure(error):
                requestError = error
            case let .success(response):
                requestResponse = response
            }

            completedExpectation.fulfill()
        })

        waitForExpectations(timeout: serverTimeout, handler: { _ in
            XCTAssert(requestResponse != nil, "нет ответа сервера")
            XCTAssert(requestError == nil, "Ошибки не должно быть, что-то изменилось в ответе сервера.")
        })
    }

    /**
     * Создание запроса и ожидание ответа от сервера.
     * Запрос ждем 30 секунд.
     * Тест считается удачным если в течении этого времени сервер обработает запрос и ответит ошибкой что сумма в чеке не совпадает с суммой платежа.
     */
    func test_InitRequestWrongReceipt() {
        let completedExpectation = expectation(description: "Completed")

        /// Сумма платежа
        let paymenyAmount: Int64 = 20000

        /// Сумма указаныне в чеке
        let receiptItemAmount: Int64 = 10000

        let jsonPaymentData =
            """
            {
            	"Amount": \(paymenyAmount),
            	"OrderId": \(arc4random()),
            	"CustomerKey": \"\(ASDKStageTestData.customerKey)\",
            	"Receipt": {
            		"Email": "a@test.ru",
            		"Items":[
            			{
            				"Amount": \(receiptItemAmount),
            				"Name": "123",
            				"Price": 20000,
            				"Quantity": 1,
            				"Tax": "vat10"
            			}
            		],
            		"Taxation": "osn"
            	}
            }
            """

        var requestError: Error?

        let data = Data(jsonPaymentData.utf8)
        guard let paymentData = try? JSONDecoder().decode(PaymentInitData.self, from: data) else {
            XCTAssert(false, "Не удалось создать данные для платежа")
            return
        }

        _ = sdk?.paymentInit(data: paymentData, completionHandler: { response in
            switch response {
            case let .failure(error):
                requestError = error
            case .success:
                break
            }

            completedExpectation.fulfill()
        })

        waitForExpectations(timeout: serverTimeout, handler: { _ in
            XCTAssert(requestError != nil, "Сервер должен вернуть ошибку в виде: '{\"Success\":false,\"ErrorCode\":\"308\",\"Message\":\"Суммы в чеке и в платеже не совпадают.\"}'")
        })
    }

    /**
     * Создание запроса на подтверждение платежа  и ожидание ответа от сервера.
     * Запрос ждем 30 секунд.
     * Тест считается удачным если в течении этого времени сервер обработает запрос и ответит ошибкой.
     */
    func test_FinishRequest() {
        let completedExpectation = expectation(description: "Completed")
        var requestError: Error?

        /// Данные платежной карты сформированы на основе тестовых данных с `https://oplata.tinkoff.ru/landing/develop/test`
        /// Номер платежа недействительный
        let paymentData = PaymentFinishRequestData(paymentId: 1, paymentSource: PaymentSourceData.cardNumber(number: "5182230000000010", expDate: "1122", cvv: "111"))

        _ = sdk?.paymentFinish(data: paymentData, completionHandler: { response in
            switch response {
            case let .failure(error):
                requestError = error
            case .success:
                break
            }

            completedExpectation.fulfill()
        })

        waitForExpectations(timeout: serverTimeout, handler: { _ in
            XCTAssert(requestError != nil, "Сервер должен вернуть ошибку в виде: '{\"Success\":false,\"ErrorCode\":\"9999\",\"Message\":\"Неверные параметры.\", \"Details\":\"Транзакция не найдена.\"}' ")
        })
    }

    /**
     * Совершение платежа
     * Запрос ждем 30 секунд.
     * Тест считается удачным если в течении этого времени сервер обработает запрос и вернет статус платежа.
     */
    func test_Pay() {
        let completedExpectation = expectation(description: "Completed")

        let jsonPaymentData =
            """
            {
            	"Amount": 20000,
            	"OrderId": \(arc4random()),
            	"CustomerKey": \"\(ASDKStageTestData.customerKey)\",
            	"Receipt": {
            	"Email": "test@gmail.com",
            	"Items": [ {
            				"Amount": 20000,
            				"Name": "123",
            				"Price": 20000,
            				"Quantity": 1,
            				"Tax": "vat10"
            			}
            		],
            	"Taxation": "osn"
            	}
            }
            """

        var requestError: Error?
        var requestResponseInit: PaymentInitResponse?
        var requestResponseFinish: PaymentFinishResponse?
        let data = Data(jsonPaymentData.utf8)

        guard let paymentData = try? JSONDecoder().decode(PaymentInitData.self, from: data) else {
            XCTAssert(false, "не удалось создать данные для платежа")
            return
        }

        _ = sdk?.paymentInit(data: paymentData, completionHandler: { response in
            switch response {
            case let .failure(error):
                requestError = error
            case let .success(response):

                requestResponseInit = response
                /// Данные платежной карты сформированы на основе тестовых данных с `https://oplata.tinkoff.ru/landing/develop/test`
                let paymentData = PaymentFinishRequestData(paymentId: response.paymentId, paymentSource: PaymentSourceData.cardNumber(number: "5182230000000010", expDate: "1122", cvv: "111"))

                _ = self.sdk?.paymentFinish(data: paymentData, completionHandler: { response in
                    switch response {
                    case let .failure(error):
                        requestError = error
                    case let .success(response):

                        // игнорируем response.finishResponseStatus - needConfirmation, если ответ есть то сервер платеж обработал.
                        requestResponseFinish = response
                    }

                    completedExpectation.fulfill()
                }) // paymentFinish
            } // switch response
        }) // paymentInit

        waitForExpectations(timeout: serverTimeout, handler: { _ in
            XCTAssert(requestResponseInit != nil, "нет ответа сервера")
            XCTAssert(requestResponseFinish != nil, "нет ответа сервера")
            //
            XCTAssert(requestError == nil, requestError?.localizedDescription ?? "Ошибки не должно быть, что-то изменилось в ответе сервера.")
        })
    }
}
