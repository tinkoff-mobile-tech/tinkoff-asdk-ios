//
//
//  DefaultNetworkClientIntegrationTests.swift
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

class DefaultNetworkClientIntegrationTests: XCTestCase {

    let networkRequestExpectationTimeout: TimeInterval = 5

    let url = URL(string: "https://tinkoff.ru")!
    let urlRequestPerformer = MockRequestPerformer()
    lazy var networkClient = DefaultNetworkClient(
        urlRequestPerfomer: urlRequestPerformer,
        hostProvider: url,
        requestBuilder: DefaultNetworkClientRequestBuilder(),
        responseValidator: DefaultHTTPURLResponseValidator()
    )

    override func setUp() {
        urlRequestPerformer.request = nil
        urlRequestPerformer.data = nil
        urlRequestPerformer.urlResponse = nil
        urlRequestPerformer.error = nil
        urlRequestPerformer.dataTaskMethodCalled = false
    }

    func testIfNetworkClientCallsUrlRequestPerformerDataTaskMethod() {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { [urlRequestPerformer] _ in
            XCTAssertTrue(urlRequestPerformer.dataTaskMethodCalled, "urlRequestPerformer's dataTask method must be called when networkClient perform request")

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testIfErrorResponseAndDataAreNilInNetworkClientResultIfBothWereNotPassedFromRequestPerformer() {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            XCTAssertNil(response.data)
            XCTAssertNil(response.response)
            XCTAssertNil(response.error)

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testIfErrorResponseAndDataAreNotNilInNetworkClientResultIfBothWerePassedFromRequestPerformer() {
        let error = NSError(domain: "ru.tinkoff.testError", code: 666, userInfo: nil)

        let data = "some string".data(using: .utf8)

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )

        urlRequestPerformer.error = error
        urlRequestPerformer.data = data
        urlRequestPerformer.urlResponse = response

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            XCTAssertNotNil(response.data)
            XCTAssertNotNil(response.response)
            XCTAssertNotNil(response.error)

            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testTransportErrorIfErrorNotNil() {
        let error = NSError(domain: "ru.tinkoff.testError", code: 666, userInfo: nil)
        urlRequestPerformer.error = error

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            switch response.result {
            case let .failure(resultError):
                guard let networkError = resultError as? NetworkError,
                      case let .transportError(underlyingError) = networkError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(underlyingError as NSError, error)
            case .success:
                XCTFail()
            }

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testServerErrorWith401StatusCodeAndWithoutData() {
        let errorStatusCode = 401
        let response = HTTPURLResponse(url: url, statusCode: errorStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)
        urlRequestPerformer.urlResponse = response

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            switch response.result {
            case let .failure(resultError):
                guard let networkError = resultError as? NetworkError,
                      case let .serverError(statusCode, data) = networkError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(statusCode, errorStatusCode)
                XCTAssertNil(data)
            case .success:
                XCTFail()
            }

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testServerErrorWith401StatusCodeAndWithData() {
        let errorStatusCode = 401
        let response = HTTPURLResponse(url: url, statusCode: errorStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)
        let data = "some string".data(using: .utf8)

        urlRequestPerformer.urlResponse = response
        urlRequestPerformer.data = data

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            switch response.result {
            case let .failure(resultError):
                guard let networkError = resultError as? NetworkError,
                      case let .serverError(statusCode, data) = networkError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(statusCode, errorStatusCode)
                XCTAssertNotNil(data)
            case .success:
                XCTFail()
            }

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testNoDataErrorWith200StatusCodeAndNoDataFromPerformer() {
        let successStatusCode = 200
        let response = HTTPURLResponse(url: url, statusCode: successStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)

        urlRequestPerformer.urlResponse = response

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            switch response.result {
            case let .failure(resultError):
                guard let networkError = resultError as? NetworkError,
                      case .noData = networkError else {
                    XCTFail()
                    return
                }
            case .success:
                XCTFail()
            }

            requestExpectation.fulfill()
        }

        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }

    func testDataReturnedInResponse() {
        let successStatusCode = 200
        let response = HTTPURLResponse(url: url, statusCode: successStatusCode, httpVersion: "HTTP/1.1", headerFields: nil)
        let performerData = "some string".data(using: .utf8)

        urlRequestPerformer.urlResponse = response
        urlRequestPerformer.data = performerData

        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)

        let requestExpectation = XCTestExpectation()
        networkClient.performRequest(request) { response in
            switch response.result {
            case .failure:
                XCTFail()
            case let .success(data):
                XCTAssertNotNil(data)
                XCTAssertEqual(data, performerData)
            }

            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: networkRequestExpectationTimeout)
    }
}
