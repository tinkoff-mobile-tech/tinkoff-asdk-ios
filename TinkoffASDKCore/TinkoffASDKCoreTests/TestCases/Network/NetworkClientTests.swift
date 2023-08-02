//
//  NetworkClientTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
import XCTest

final class NetworkClientTests: XCTestCase {
    private var session: NetworkSessionMock!
    private var requestBuilder: URLRequestBuilderMock!
    private var statusCodeValidator: HTTPStatusCodeValidatorMock!
    private var logger: LoggerMock!
    private var sut: NetworkClient!

    override func setUp() {
        super.setUp()
        session = NetworkSessionMock()
        requestBuilder = URLRequestBuilderMock()
        statusCodeValidator = HTTPStatusCodeValidatorMock()
        logger = LoggerMock()
        sut = NetworkClient(
            session: session,
            requestBuilder: requestBuilder,
            statusCodeValidator: statusCodeValidator,
            logger: logger
        )
    }

    override func tearDown() {
        session = nil
        requestBuilder = nil
        statusCodeValidator = nil
        sut = nil
        super.tearDown()
    }

    func test_performRequest_withValidResults_shouldCallbackNetworkResponse() {
        // given
        let request = NetworkRequestStub()

        // when
        let result = performRequestWaiting(request)

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 1)
        XCTAssertEqual(session.dataTaskCallsCount, 1)
        XCTAssertEqual(session.dataTaskReturnValue.invokedResumeCount, 1)
        XCTAssertFalse(session.dataTaskReturnValue.invokedCancel)
        XCTAssertEqual(statusCodeValidator.invokedValidateCount, 1)
        XCTAssertNoThrow(try result.get())
    }

    func test_performRequest_withFailedURLRequestBuilding_shouldCallbackRequestBuildingError() {
        // given
        let requestBuildingError = ErrorStub()
        requestBuilder.buildThrowableError = requestBuildingError

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 0)
        XCTAssertEqual(session.dataTaskCallsCount, 0)
        XCTAssertFalse(statusCodeValidator.invokedValidate)

        XCTAssertThrowsError(try result.get()) { error in
            guard case let NetworkError.failedToCreateRequest(error as ErrorStub) = error,
                  error == requestBuildingError else {
                return XCTFail()
            }
        }
    }

    func test_performRequest_withSessionError_shouldCallbackTransportError() {
        // given
        let sessionError = ErrorStub()
        session.dataTaskCompletionClosureInput = (Data(), HTTPURLResponse(), sessionError)

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 1)
        XCTAssertEqual(session.dataTaskCallsCount, 1)
        XCTAssertFalse(statusCodeValidator.invokedValidate)

        XCTAssertThrowsError(try result.get()) { error in
            guard case let NetworkError.transportError(error as ErrorStub) = error,
                  error == sessionError else {
                return XCTFail()
            }
        }
    }

    func test_performRequest_withEmptySessionData_shouldCallbackEmptyResponseError() {
        // given
        session.dataTaskCompletionClosureInput = (nil, HTTPURLResponse(), nil)

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 1)
        XCTAssertEqual(session.dataTaskCallsCount, 1)
        XCTAssertEqual(statusCodeValidator.invokedValidateCount, 1)

        XCTAssertThrowsError(try result.get()) { error in
            guard case NetworkError.emptyResponse = error else {
                return XCTFail()
            }
        }
    }

    func test_performRequest_withInvalidURLResponse_shouldCallbackEmptyResponseError() {
        // given
        session.dataTaskCompletionClosureInput = (Data(), URLResponse(), nil)

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 1)
        XCTAssertEqual(session.dataTaskCallsCount, 1)
        XCTAssertFalse(statusCodeValidator.invokedValidate)

        XCTAssertThrowsError(try result.get()) { error in
            guard case NetworkError.emptyResponse = error else {
                return XCTFail()
            }
        }
    }

    func test_performRequest_withInvalidHTTPStatusCode_shouldCallbackServerError() {
        // given
        let stubbedStatusCode = 101
        let httpResponse = HTTPURLResponse(url: .doesNotMatter, statusCode: stubbedStatusCode, httpVersion: nil, headerFields: nil)
        session.dataTaskCompletionClosureInput = (Data(), httpResponse, nil)
        statusCodeValidator.stubbedValidateResult = false

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestBuilder.buildCallsCount, 1)
        XCTAssertEqual(session.dataTaskCallsCount, 1)
        XCTAssert(statusCodeValidator.invokedValidate)

        XCTAssertThrowsError(try result.get()) { error in
            guard case let NetworkError.serverError(statusCode) = error,
                  statusCode == stubbedStatusCode else {
                return XCTFail()
            }
        }
    }

    // MARK: Helpers

    private func performRequestWaiting(
        _ request: NetworkRequest = NetworkRequestStub(),
        function: String = #function
    ) -> Result<NetworkResponse, NetworkError> {
        let expectation = expectation(description: function)
        var result: Result<NetworkResponse, NetworkError>!

        sut.performRequest(request) {
            result = $0
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        return result
    }
}
