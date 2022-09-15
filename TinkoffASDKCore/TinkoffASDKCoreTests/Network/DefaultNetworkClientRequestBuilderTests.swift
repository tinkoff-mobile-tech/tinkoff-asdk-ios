//
//
//  DefaultNetworkClientRequestBuilderTests.swift
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

class DefaultNetworkClientRequestBuilderTests: XCTestCase {

    let builder = DefaultNetworkClientRequestBuilder()

    func testNoErrorBuildWithCorrectURLAndPath() {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)
        XCTAssertNoThrow(try builder.buildURLRequest(request: request, requestAdapter: nil))
    }

    func testBuildFailedWithErrorWithEmptyPath() {
        let request = TestsNetworkRequest(path: [], httpMethod: .get)
        XCTAssertThrowsError(try builder.buildURLRequest(request: request, requestAdapter: nil))
    }

    func testBuildCorrectUrlWithOneItemPath() throws {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)
        let urlRequest = try builder.buildURLRequest(request: request, requestAdapter: nil)

        XCTAssertEqual(urlRequest.url?.absoluteString, request.baseURL.absoluteString + "/test")
    }

    func testBuildCorrectUrlWithThreeItemsPath() throws {
        let request = TestsNetworkRequest(path: ["test", "url", "builder"], httpMethod: .get)
        let urlRequest = try builder.buildURLRequest(request: request, requestAdapter: nil)
        XCTAssertEqual(urlRequest.url?.absoluteString, request.baseURL.absoluteString + "/test/url/builder")
    }

    func testBuilderSetHeadersFromRequest() throws {
        let headers = ["headerKey": "headerValue"]
        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .get,
            headers: headers
        )
        let urlRequest = try builder.buildURLRequest(request: request, requestAdapter: nil)
        XCTAssertEqual(headers, urlRequest.allHTTPHeaderFields)
    }

    func testJSONParametersEncoding() throws {
        let parameters: [String: Any] = ["param1": true, "param2": "value2", "param3": 10]

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post,
            parameters: parameters
        )

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: nil
        )
        let urlRequestBodyJSON = try? JSONSerialization.jsonObject(
            with: urlRequest.httpBody!,
            options: []
        ) as? [String: Any]
        XCTAssertEqual(
            NSDictionary(dictionary: urlRequestBodyJSON!),
            NSDictionary(dictionary: parameters)
        )
    }

    func testJSONParametersEncodingSetCorrectContentTypeIfNotSetBefore() throws {
        let parameters: [String: Any] = ["param1": true, "param2": "value2", "param3": 10]

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post,
            parameters: parameters
        )

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: nil
        )
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testJSONParametersEncodingDoesntSetContentTypeIfSetBefore() throws {
        let parameters: [String: Any] = ["param1": true, "param2": "value2", "param3": 10]

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post,
            parameters: parameters,
            headers: ["Content-Type": "anything"]
        )

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: nil
        )
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "anything")
    }

    func testBuilderCallsNetworkRequestAdapterParametersAndHeadersMethod() throws {
        let mockRequestAdapter = MockNetworkRequestAdapter()

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post
        )

        _ = try builder.buildURLRequest(
            request: request,
            requestAdapter: mockRequestAdapter
        )

        XCTAssertTrue(
            mockRequestAdapter.isAdditionalHeadersMethodCalled,
            "additionalHeaders(for request: NetworkRequest) method must be called"
        )
        XCTAssertTrue(
            mockRequestAdapter.isAdditionalParametersMethodCalled,
            "additionalParameters(for request: NetworkRequest) method must be called"
        )
    }

    func testBuilderAddAdditinalHeadersToEmptyRequestHeadersFromNetworkRequestAdapter() throws {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalHeaders = [
            "headerKey1": "headerValue1",
            "headerKey2": "headerValue2",
        ]
        mockRequestAdapter.additionalHeaders = additionalHeaders

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post
        )

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: mockRequestAdapter
        )

        XCTAssertEqual(urlRequest.allHTTPHeaderFields, additionalHeaders)
    }

    func testBuilderAddAdditinalHeadersToRequestHeadersFromNetworkRequestAdapter() throws {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalHeaders = [
            "headerKey1": "headerValue1",
            "headerKey2": "headerValue2",
        ]
        mockRequestAdapter.additionalHeaders = additionalHeaders

        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post,
            parameters: ["param1Key": "param1Value"],
            headers: ["headerKey3": "headerValue3"]
        )

        let resultHeaders = [
            "headerKey1": "headerValue1",
            "headerKey2": "headerValue2",
            "headerKey3": "headerValue3",
            "Content-Type": "application/json",
        ]

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: mockRequestAdapter
        )

        XCTAssertEqual(urlRequest.allHTTPHeaderFields, resultHeaders)
    }

    func testBuilderAddAdditinalParametersToRequestFromNetworkRequestAdapter() throws {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalParameters: HTTPParameters = [
            "additionalParamKey1": "additionalParamValue1",
            "additionalParamKey2": false,
        ]
        mockRequestAdapter.additionalParameters = additionalParameters

        let parameters: HTTPParameters = ["param1": true, "param2": "value2", "param3": 10]
        let request = TestsNetworkRequest(
            path: ["test"],
            httpMethod: .post,
            parameters: parameters
        )

        let resultParameters: HTTPParameters = [
            "param1": true,
            "param2": "value2",
            "param3": 10,
            "additionalParamKey1": "additionalParamValue1",
            "additionalParamKey2": false,
        ]

        let urlRequest = try builder.buildURLRequest(
            request: request,
            requestAdapter: mockRequestAdapter
        )

        let urlRequestBodyJSON = try? JSONSerialization.jsonObject(
            with: urlRequest.httpBody!,
            options: []
        ) as? [String: Any]
        XCTAssertEqual(
            NSDictionary(dictionary: urlRequestBodyJSON!),
            NSDictionary(dictionary: resultParameters)
        )
    }
}
