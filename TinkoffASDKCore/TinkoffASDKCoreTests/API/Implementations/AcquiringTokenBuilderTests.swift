//
//
//  AcquiringTokenBuilderTests.swift
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

class AcquiringTokenBuilderTests: XCTestCase {

    let password = "password"
    lazy var tokenBuilder = AcquiringTokenBuilder(password: password)
    
    func testTokenBuildingWithEmptyParametersAndNilRequest() {
        let parameters: HTTPParameters = [:]
        let request: TokenProvidableAPIRequest? = nil
        
        let expectedToken = password.sha256()
        
        let token = tokenBuilder.buildToken(commonParameters: parameters, request: request)
        XCTAssertEqual(token, expectedToken)
    }
    
    func testTokenBuildingWithNotEmptyParametersAndNilRequest() {
        let parameters: HTTPParameters = [APIConstants.Keys.terminalKey: "terminalKey",
                                          "OtherParameterKey": "OtherParameter"]
        let request: TokenProvidableAPIRequest? = nil
        
        let expectedTokenString = "OtherParameter\(password)\("terminalKey")"
        let expectedToken = expectedTokenString.sha256()
        
        let token = tokenBuilder.buildToken(commonParameters: parameters, request: request)
        XCTAssertEqual(token, expectedToken)
    }
    
    func testTokenBuildingWithEmptyParametersAndNotNilRequestWithTokenParameters() {
        let parameters: HTTPParameters = [:]
        var request = MockTokenProvidableAPIRequest()
        request.parameters = ["FirstParameterKey": "FirstParameter", "SecondParameterKey": 103]
        
        let expectedTokenString = "FirstParameter\(password)\(103)"
        let expectedToken = expectedTokenString.sha256()
        
        let token = tokenBuilder.buildToken(commonParameters: parameters, request: request)
        XCTAssertEqual(token, expectedToken)
    }
    
    func testTokenBuildingWithEmptyParametersAndNotNilRequestWithoutTokenParameters() {
        let parameters: HTTPParameters = [:]
        var request = MockTokenProvidableAPIRequest()
        request.parameters = ["FirstParameterKey": "FirstParameter", "SecondParameterKey": 103]
        request.tokenParameterKeysToIgnore = ["FirstParameterKey", "SecondParameterKey"]
        
        let expectedTokenString = "\(password)"
        let expectedToken = expectedTokenString.sha256()
        
        let token = tokenBuilder.buildToken(commonParameters: parameters, request: request)
        XCTAssertEqual(token, expectedToken)
    }
    
    func testTokenBuildingWithNotEmptyParametersAndNotNilRequestWithTokenParameters() {
        let parameters: HTTPParameters = [APIConstants.Keys.terminalKey: "terminalKey"]
        var request = MockTokenProvidableAPIRequest()
        request.parameters = ["FirstParameterKey": "FirstParameter", "SecondParameterKey": 103]
        
        let expectedTokenString = "FirstParameter\(password)\(103)terminalKey"
        let expectedToken = expectedTokenString.sha256()
        
        let token = tokenBuilder.buildToken(commonParameters: parameters, request: request)
        XCTAssertEqual(token, expectedToken)
    }
}
