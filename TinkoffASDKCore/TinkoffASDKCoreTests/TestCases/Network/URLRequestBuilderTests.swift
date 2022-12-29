//
//  URLRequestBuilderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
import XCTest

final class URLRequestBuilderTests: XCTestCase {
    var sut: URLRequestBuilder!

    override func setUp() {
        super.setUp()
        sut = URLRequestBuilder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_build_withEmptyPath_shouldThrowError() {
        // given
        let request = NetworkRequestStub(path: "")

        // when
        let result = Result {
            try sut.build(request: request)
        }

        // then
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssert(error is URLRequestBuilder.Error)
        }
    }

    func test_build_withValidPath_shouldNotThrowError() {
        // given
        let request = NetworkRequestStub(path: "doesNotMatter")

        // when
        let result = Result {
            try sut.build(request: request)
        }

        // then

        XCTAssertNoThrow(try result.get())
    }

    func test_build_withPostMethod_shouldBuildCorrectURLRequest() throws {
        // given
        let request = NetworkRequestStub(
            httpMethod: .post,
            headers: ["test": "test"],
            parameters: ["param1": 4, "param2": 4.5, "param3": "test"]
        )

        let expectedParamsData = try JSONSerialization.data(withJSONObject: request.parameters, options: .sortedKeys)
        let expectedHeaders = request.headers.merging([.contentType: .applicationJSON]) { $1 }

        // when
        let urlRequest = try sut.build(request: request)

        // then
        XCTAssertEqual(request.baseURL.appendingPathComponent(request.path), urlRequest.url)
        XCTAssertEqual(expectedHeaders, urlRequest.allHTTPHeaderFields)
        XCTAssertEqual(request.httpMethod.rawValue, urlRequest.httpMethod)
        XCTAssertEqual(expectedParamsData, urlRequest.httpBody)
    }

    func test_build_withGetMethod_shouldIgnoreBodyParams_and_shouldNotWriteContentType() throws {
        // given
        let request = NetworkRequestStub(
            httpMethod: .get,
            parameters: ["param1": 4, "param2": 4.5, "param3": "test"]
        )

        // when
        let urlRequest = try sut.build(request: request)

        // then
        XCTAssert(urlRequest.allHTTPHeaderFields == nil || urlRequest.allHTTPHeaderFields == [:])
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_build_withURLFormParametersEncoding_shouldReturnURLFormEncodedRequest() throws {
        // given
        let request = NetworkRequestStub(
            httpMethod: .post,
            parameters: ["param1": 4, "param2": 8, "param3": "test"],
            parametersEncoding: .urlEncodedForm
        )

        let expectedBody = try XCTUnwrap("param1=4&param2=8&param3=test".data(using: .utf8))

        // when
        let urlRequest = try sut.build(request: request)

        // then
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: .contentType), .applicationURLEncodedForm)
    }

    func test_build_withEmptyParameters_shouldReturnURLRequestWithoutBodyAndContentType() throws {
        // given
        let request = NetworkRequestStub(
            httpMethod: .post,
            headers: ["header": "value"],
            parameters: [:]
        )

        // when
        let urlRequest = try sut.build(request: request)

        // then
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertNil(urlRequest.value(forHTTPHeaderField: .contentType))
    }
}

// MARK: - String + Constants

private extension String {
    static let contentType = "Content-Type"
    static let applicationJSON = "application/json"
    static let applicationURLEncodedForm = "application/x-www-form-urlencoded"
}
