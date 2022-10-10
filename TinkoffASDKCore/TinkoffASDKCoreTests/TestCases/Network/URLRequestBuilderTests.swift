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
        sut = URLRequestBuilder(serializationOptions: .sortedKeys)
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
        let expectedHeaders = request.headers.merging(["Content-Type": "application/json"]) { $1 }

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
}
