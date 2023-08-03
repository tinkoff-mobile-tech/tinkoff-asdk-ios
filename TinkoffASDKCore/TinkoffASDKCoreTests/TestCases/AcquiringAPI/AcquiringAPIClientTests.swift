//
//  AcquiringAPIClientTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
import XCTest

final class AcquiringAPIClientTests: XCTestCase {
    private var requestAdapter: AcquiringRequestAdapterMock!
    private var networkClient: NetworkClientMock!
    private var decoder: AcquiringDecoderMock!
    private var sut: AcquiringAPIClient!

    override func setUp() {
        super.setUp()
        requestAdapter = AcquiringRequestAdapterMock()
        networkClient = NetworkClientMock()
        decoder = AcquiringDecoderMock()

        sut = AcquiringAPIClient(
            requestAdapter: requestAdapter,
            networkClient: networkClient,
            decoder: decoder
        )
    }

    override func tearDown() {
        requestAdapter = nil
        networkClient = nil
        decoder = nil
        sut = nil
        super.tearDown()
    }

    func test_performRequest_withValidResults_shouldCallbackSuccess() {
        // given
        let request = AcquiringRequestStub()

        // when
        let result = performRequestWaiting(request)

        // then
        XCTAssertEqual(requestAdapter.adaptCallsCount, 1)
        XCTAssertEqual(networkClient.performRequestCallsCount, 1)
        XCTAssertEqual(decoder.invokedDecodeCount, 1)
        XCTAssertNoThrow(try result.get())
    }

    func test_performRequest_shouldPassAdaptedRequestToNetworkClient() throws {
        // given
        let initialRequest = AcquiringRequestStub()
        let adaptedRequest = AcquiringRequestStub(headers: ["some": "anotherValue"])

        requestAdapter.adaptCompletionClosureInput = .success(adaptedRequest)

        // when
        _ = performRequestWaiting(initialRequest)

        // then
        let requestPassedToAdapter = try XCTUnwrap(requestAdapter.adaptReceivedArguments?.request as? AcquiringRequestStub)
        XCTAssertEqual(requestPassedToAdapter, initialRequest)
        let requestPassedToNetworkClient = try XCTUnwrap(networkClient.performRequestReceivedArguments?.request as? AcquiringRequestStub)
        XCTAssertEqual(requestPassedToNetworkClient, adaptedRequest)
    }

    func test_performRequest_withFailedAdaptation_shouldCallbackError() {
        // given
        requestAdapter.adaptCompletionClosureInput = .failure(ErrorStub())

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(requestAdapter.adaptCallsCount, 1)
        XCTAssertEqual(networkClient.performRequestCallsCount, 0)

        XCTAssertThrowsError(try result.get())
    }

    func test_performRequest_withFailedNetworkResponse_shouldCallbackError() {
        // given
        networkClient.performRequestCompletionClosureInput = .failure(.emptyResponse)

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertEqual(networkClient.performRequestCallsCount, 1)
        XCTAssertThrowsError(try result.get())
    }

    func test_performRequest_withFailedDecoding_shouldCallbackDecodersError() {
        // given
        let decodingError = ErrorStub()
        decoder.stubbedDecodeError = decodingError

        // when
        let result = performRequestWaiting()

        // then
        XCTAssertThrowsError(try result.get()) { error in
            guard let error = error as? ErrorStub, error == decodingError else {
                return XCTFail()
            }
        }
    }

    func test_performRequest_shouldNotCallback_whenCalledCancelOnAdaptationStep() {
        // given
        let request = AcquiringRequestStub()
        let adaptationQueue = DispatchQueue(label: #function, attributes: .initiallyInactive)
        let expectation = expectation(description: #function)

        requestAdapter.adaptCompletionClosure = { completion in
            adaptationQueue.async {
                completion(.success(request))
                expectation.fulfill()
            }
        }

        // when
        let cancellable = sut.performRequest(request) { (performingResult: Result<EmptyDecodable, Error>) in
            XCTFail("This closure should not be called")
        }

        cancellable.cancel()
        adaptationQueue.activate()
        waitForExpectations(timeout: 1)

        // then
        XCTAssertEqual(requestAdapter.adaptCallsCount, 1)
        XCTAssertEqual(networkClient.performRequestCallsCount, 0)
    }

    func test_performRequest_shouldNotCallback_whenCalledCancelOnNetworkPerformingStep() {
        // given
        let request = AcquiringRequestStub()
        let networkingQueue = DispatchQueue(label: #function, attributes: .initiallyInactive)
        let expectation = expectation(description: #function)

        networkClient.performRequestCompletionClosure = { completion in
            networkingQueue.async {
                completion(.success(.stub()))
                expectation.fulfill()
            }
        }

        requestAdapter.adaptCompletionClosureInput = .success(request)

        // when
        let cancellable = sut.performRequest(request) { (performingResult: Result<EmptyDecodable, Error>) in
            XCTFail("This closure should not be called")
        }

        cancellable.cancel()
        networkingQueue.activate()
        waitForExpectations(timeout: 1)

        // then
        XCTAssertEqual(requestAdapter.adaptCallsCount, 1)
        XCTAssertEqual(networkClient.performRequestCallsCount, 1)
        XCTAssertFalse(decoder.invokedDecode)
    }

    // MARK: Helpers

    private func performRequestWaiting(
        _ request: AcquiringRequest = AcquiringRequestStub(),
        function: String = #function
    ) -> Result<Void, Error> {
        performRequestWaiting(request, resultType: EmptyDecodable.self, function: function)
            .map { _ in () }
    }

    private func performRequestWaiting<T: Decodable>(
        _ request: AcquiringRequest,
        resultType: T.Type,
        function: String = #function
    ) -> Result<T, Error> {
        let expectation = expectation(description: function)
        var result: Result<T, Error>!

        _ = sut.performRequest(request) { (performingResult: Result<T, Error>) in
            result = performingResult
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        return result
    }
}
