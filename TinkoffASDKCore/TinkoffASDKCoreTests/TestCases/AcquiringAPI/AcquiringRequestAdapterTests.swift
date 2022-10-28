//
//  AcquiringRequestAdapterTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
import XCTest

final class AcquiringRequestAdapterTests: XCTestCase {
    private var terminalKeyProvider: StringProviderMock!
    private var tokenProvider: TokenProviderMock!
    private var sut: AcquiringRequestAdapter!

    override func setUp() {
        super.setUp()
        terminalKeyProvider = StringProviderMock()
        tokenProvider = TokenProviderMock()
        sut = AcquiringRequestAdapter(
            terminalKeyProvider: terminalKeyProvider,
            tokenProvider: tokenProvider
        )
    }

    override func tearDown() {
        terminalKeyProvider = nil
        tokenProvider = nil
        sut = nil
    }

    func test_adapt_withoutAnyAdaptingStrategies_shouldCallbackSameRequest() throws {
        // given
        let request = AcquiringRequestStub(
            parameters: ["test": "test"],
            terminalKeyProvidingStrategy: .never,
            tokenFormationStrategy: .none
        )

        // when
        let result = adaptWaiting(request: request)

        // then
        let adaptedRequest = try (result.get() as? AcquiringRequestStub).xctUnwrapped()
        XCTAssertEqual(adaptedRequest, request)
    }

    func test_adapt_withMethodDependantTerminalKeyStrategy_shouldCallbackRequestWithTerminalKey() throws {
        // given
        let initialParameters = ["one": "two"]

        let request = AcquiringRequestStub(
            parameters: initialParameters,
            terminalKeyProvidingStrategy: .always,
            tokenFormationStrategy: .none
        )

        let stubbedTerminalKey = "testKey"
        terminalKeyProvider.stubbedValue = stubbedTerminalKey

        // when
        let result = adaptWaiting(request: request)

        // then
        let adaptedRequest = try result.get()
        let expectedParameters = initialParameters.merging([Constants.Keys.terminalKey: stubbedTerminalKey]) { $1 }

        XCTAssert(adaptedRequest.parameters.isEqual(to: expectedParameters))
    }

    func test_adapt_withTokenFormationStrategy_shouldCallbackRequestWithToken() throws {
        // given
        let initialParameters = ["one": "two"]

        let request = AcquiringRequestStub(
            parameters: initialParameters,
            terminalKeyProvidingStrategy: .never,
            tokenFormationStrategy: .includeAll()
        )

        let stubbedToken = "testToken"
        tokenProvider.provideTokenMethodStub = { _, completion in completion(.success(stubbedToken)) }

        // when
        let result = adaptWaiting(request: request)

        // then
        let adaptedRequest = try result.get()
        let expectedParameters = initialParameters.merging([Constants.Keys.token: stubbedToken]) { $1 }

        XCTAssert(adaptedRequest.parameters.isEqual(to: expectedParameters))
    }

    func test_adapt_withMethodDependantTerminalKeyAndTokenStrategies_shouldCallbackRequestWithTerminalKeyAndToken() throws {
        // given
        let initialParameters = [
            "one": "two",
            "three": "fourth",
        ]

        let stubbedTerminalKey = "testKey"
        let stubbedToken = "token"
        terminalKeyProvider.stubbedValue = stubbedTerminalKey
        tokenProvider.provideTokenMethodStub = { _, completion in
            completion(.success(stubbedToken))
        }

        let request = AcquiringRequestStub(parameters: initialParameters, tokenFormationStrategy: .includeAll())

        // when
        let result = adaptWaiting(request: request)

        // then
        let adaptedRequest = try result.get()
        let expectedParameters = initialParameters
            .merging([
                Constants.Keys.terminalKey: stubbedTerminalKey,
                Constants.Keys.token: stubbedToken,
            ]) { $1 }

        XCTAssert(adaptedRequest.parameters.isEqual(to: expectedParameters))
    }

    func test_adapt_shouldPassOnlyNeededParametersWithTerminalKeyToTokenProvider() {
        // given
        let includedParameters: [String: Any] = [
            "some": "value",
            "value": "some",
            "digit": 5,
        ]

        let requestParameters = includedParameters.merging(["object": ErrorStub()]) { $1 }
        let request = AcquiringRequestStub(parameters: requestParameters, tokenFormationStrategy: .includeAll(except: "object"))

        let stubbedTerminalKey = "key"
        terminalKeyProvider.stubbedValue = stubbedTerminalKey

        // when
        _ = adaptWaiting(request: request)

        // then
        let expectedParameters = includedParameters
            .mapValues { String(describing: $0) }
            .merging([Constants.Keys.terminalKey: stubbedTerminalKey]) { $1 }

        XCTAssertEqual(tokenProvider.invokedProvideTokenParameters, expectedParameters)
    }

    func test_adapt_withFailedTokenProviding_shouldCallbackError() {
        // given
        let request = AcquiringRequestStub(parameters: ["some": 4], tokenFormationStrategy: .includeAll())
        let tokenProvidingError = ErrorStub()
        tokenProvider.provideTokenMethodStub = { _, completion in
            DispatchQueue.global().async {
                completion(.failure(tokenProvidingError))
            }
        }

        // when
        let result = adaptWaiting(request: request)

        // then
        XCTAssertThrowsError(try result.get()) { error in
            guard error is ErrorStub else {
                return XCTFail()
            }
        }
    }

    // MARK: Helpers

    private func adaptWaiting(request: AcquiringRequest = AcquiringRequestStub(), description: String = #function) -> Result<AcquiringRequest, Error> {
        let expectation = expectation(description: description)
        var result: Result<AcquiringRequest, Error>!

        sut.adapt(request: request) { adaptingResult in
            result = adaptingResult
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        return result
    }
}
