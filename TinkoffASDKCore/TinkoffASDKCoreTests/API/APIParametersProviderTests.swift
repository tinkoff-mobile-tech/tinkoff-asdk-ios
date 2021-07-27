//
//
//  APIParametersProviderTests.swift
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

class APIParametersProviderTests: XCTestCase {
    
    let terminalKey = "TerminalKey"
    lazy var apiParametersProvider = APIParametersProvider(terminalKey: terminalKey)
    
    func testProvidedAdditionalParametersContainCustomerKeyTerminalKeyAndToken() {
        let mockRequest = MockAPIRequest<String>()
        
        let expectedAdditionalParameters =
            [
                APIConstants.Keys.terminalKey: terminalKey
            ]
        
        let additionalParameters = apiParametersProvider.additionalParameters(for: mockRequest)
        
        XCTAssertEqual(NSDictionary(dictionary: additionalParameters),
                       NSDictionary(dictionary: expectedAdditionalParameters))
    }
}
