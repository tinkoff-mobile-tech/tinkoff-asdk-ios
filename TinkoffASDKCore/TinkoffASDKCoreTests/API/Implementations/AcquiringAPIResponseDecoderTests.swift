//
//
//  AcquiringAPIResponseDecoderTests.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

class AcquiringAPIResponseDecoderTests: XCTestCase {
    
    struct MockPayload: Decodable, Equatable {
        let parameter1: String
        let parameter2: Int
    }

    let decoder = AcquiringAPIResponseDecoder(decoder: JSONDecoder())
    
    func testDecodeWithStandartStrategySuccess() {
        let responseString = """
            {
                "\(APIConstants.Keys.success)": true,
                "\(APIConstants.Keys.terminalKey)": "terminalKey",
                "\(APIConstants.Keys.errorCode)": "0",
                "parameter1": "parameter1value",
                "parameter2": 302
            }
        """
        let responseData = responseString.data(using: .utf8)!
        
        let apiRequest = MockAPIRequest<MockPayload>(decodeStrategy: .standart)
        
        let response = try! decoder.decode(data: responseData, for: apiRequest)
        
        let resultPayload = MockPayload(parameter1: "parameter1value", parameter2: 302)
        XCTAssertEqual(try! response.result.get(), resultPayload)
    }
    
    func testDecodeWithStandartStrategyFailure() {
        let errorMessage = "This is error message"
        let errorDetails = "This is error details"
        let errorCode = 333
        
        let responseString = """
            {
                "\(APIConstants.Keys.success)": false,
                "\(APIConstants.Keys.terminalKey)": "terminalKey",
                "\(APIConstants.Keys.errorCode)": "\(errorCode)",
                "\(APIConstants.Keys.errorMessage)": "\(errorMessage)",
                "\(APIConstants.Keys.errorDetails)": "\(errorDetails)"
            }
        """
        let responseData = responseString.data(using: .utf8)!
        
        let apiRequest = MockAPIRequest<MockPayload>(decodeStrategy: .standart)
        
        let response = try! decoder.decode(data: responseData, for: apiRequest)
        
        switch response.result {
        case let .failure(error):
            XCTAssertEqual(error.errorMessage, errorMessage)
            XCTAssertEqual(error.errorDetails, errorDetails)
            XCTAssertEqual(error.errorCode, errorCode)
        case .success:
            XCTFail()
        }
    }
    
    func testDecodeWithClippedStrategyCorrectAPIResponse() {
        let responseString = """
            [
                {
                    "parameter1": "parameter1value",
                    "parameter2": 302
                },
                {
                    "parameter1": "parameter1value1",
                    "parameter2": 100
                }
            ]
        """
        let responseData = responseString.data(using: .utf8)!
        
        let apiRequest = MockAPIRequest<[MockPayload]>(httpMethod: .post, decodeStrategy: .clipped)
        
        let response = try! decoder.decode(data: responseData, for: apiRequest)
        XCTAssertTrue(response.success)
    }

    func testDecodeWithClippedStrategyCorrectPayload() {
        let responseString = """
            [
                {
                    "parameter1": "parameter1value",
                    "parameter2": 302
                },
                {
                    "parameter1": "parameter1value1",
                    "parameter2": 100
                }
            ]
        """
        let responseData = responseString.data(using: .utf8)!
        
        let apiRequest = MockAPIRequest<[MockPayload]>(httpMethod: .post, decodeStrategy: .clipped)
        
        let response = try! decoder.decode(data: responseData, for: apiRequest)
        
        let resultPayload = [MockPayload(parameter1: "parameter1value", parameter2: 302),
                             MockPayload(parameter1: "parameter1value1", parameter2: 100)]
        XCTAssertEqual(try! response.result.get(), resultPayload)
    }
    
    func testDecoderWithClippedStrategyFailure() {
        let errorMessage = "Неверный статус покупателя."
        let errorDetails = "Покупатель не найден."
        let errorCode = 7
        
        let responseString = """
            {
                "\(APIConstants.Keys.success)": false,
                "\(APIConstants.Keys.errorCode)": "\(errorCode)",
                "\(APIConstants.Keys.errorMessage)": "\(errorMessage)",
                "\(APIConstants.Keys.errorDetails)": "\(errorDetails)",
                "\(APIConstants.Keys.customerKey)": "customerKey"
            }
        """
        let responseData = responseString.data(using: .utf8)!
        
        let apiRequest = MockAPIRequest<MockPayload>(decodeStrategy: .clipped)
        
        let response = try! decoder.decode(data: responseData, for: apiRequest)
        
        switch response.result {
        case let .failure(error):
            XCTAssertEqual(error.errorMessage, errorMessage)
            XCTAssertEqual(error.errorDetails, errorDetails)
            XCTAssertEqual(error.errorCode, errorCode)
        case .success:
            XCTFail()
        }
    }
}
