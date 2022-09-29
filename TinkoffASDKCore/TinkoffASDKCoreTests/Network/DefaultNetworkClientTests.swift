//
//
//  DefaultNetworkClientTests.swift
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

class DefaultNetworkClientTests: XCTestCase {

    let url = URL(string: "https://tinkoff.ru")!
    let urlRequestPerformer = MockRequestPerformer()
    let requestBuilder = MockRequestBuilder()
    let responseValidator = MockHTTPURLResponseValidator()

    lazy var networkClient = NetworkClient(
        urlRequestPerfomer: urlRequestPerformer,
        requestBuilder: requestBuilder,
        responseValidator: responseValidator
    )

    override func setUp() {
        urlRequestPerformer.dataTaskMethodCalled = false
        requestBuilder.buildURLRequestMethodCalled = false
        responseValidator.validateMethodCalled = false
    }

    func testIfRequestBuilderBuildURLRequestMethodCalled() {
        let request = TestsNetworkRequest(path: ["path"], httpMethod: .get)
        networkClient.performRequest(request) { [requestBuilder] _ in
            XCTAssertTrue(requestBuilder.buildURLRequestMethodCalled)
        }
    }

    func testIfURLRequestPerformerDataTaskMethodCalled() {
        let request = TestsNetworkRequest(path: ["path"], httpMethod: .get)
        networkClient.performRequest(request) { [urlRequestPerformer] _ in
            XCTAssertTrue(urlRequestPerformer.dataTaskMethodCalled)
        }
    }

    func testIfValidatorNotCalledIfRequestWithTransportError() {
        let request = TestsNetworkRequest(path: ["path"], httpMethod: .get)

        let error = NSError(domain: "domain", code: 666, userInfo: nil)
        urlRequestPerformer.error = error

        networkClient.performRequest(request) { [responseValidator] _ in
            XCTAssertFalse(responseValidator.validateMethodCalled)
        }
    }

    func testIfValidatorCalledIfRequestWithoutTransportErrorAndResponseNotNil() {
        let request = TestsNetworkRequest(path: ["path"], httpMethod: .get)

        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        urlRequestPerformer.urlResponse = response

        networkClient.performRequest(request) { [responseValidator] _ in
            XCTAssertTrue(responseValidator.validateMethodCalled)
        }
    }
}
