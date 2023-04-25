//
//  TDSControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.04.2023.
//

import ThreeDSWrapper
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class TDSControllerTests: BaseTestCase {

    var sut: TDSController!

    // Mocks

    var acquiringThreeDSServiceMock: AcquiringThreeDsServiceMock!
    var tDSWrapperMock: TDSWrapperMock!
    var timeoutResolverMock: TimeoutResolverMock!
    var transactionMock: TransactionMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        acquiringThreeDSServiceMock = AcquiringThreeDsServiceMock()
        tDSWrapperMock = TDSWrapperMock()
        timeoutResolverMock = TimeoutResolverMock()

        let transactionMocked = TransactionMock()
        transactionMock = transactionMocked

        tDSWrapperMock.createTransactionReturnValue = transactionMock

        sut = TDSController(
            threeDsService: acquiringThreeDSServiceMock,
            tdsWrapper: tDSWrapperMock,
            tdsTimeoutResolver: timeoutResolverMock
        )
    }

    override func tearDown() {
        acquiringThreeDSServiceMock = nil
        tDSWrapperMock = nil
        timeoutResolverMock = nil
        transactionMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_startAppBasedFlow() throws {
        // given
        let expectation = XCTestExpectation(description: #function)
        transactionMock.getAuthenticationRequestParametersReturnValue = .fake()
        transactionMock.getProgressViewReturnValue = .fake()
        transactionMock.getProgressViewClosure = { expectation.fulfill() }

        // when

        let _ = try sut.startAppBasedFlow(
            directoryServerID: .doesntMatter,
            messageVersion: .doesntMatter
        )

        wait(for: [expectation], timeout: .defaultAnimationDuration)

        // then
        XCTAssertEqual(transactionMock.getAuthenticationRequestParametersCallsCount, 1)
        XCTAssertEqual(transactionMock.getProgressViewCallsCount, 1)
    }

    func test_doChallenge() throws {
        allureId(2358075)
        // given
        try setupStartAppBasedFlow()
        timeoutResolverMock.underlyingChallengeValue = 1

        // when
        sut.doChallenge(with: .fake())

        // then
        XCTAssertEqual(transactionMock.doChallengeCallsCount, 1)
        XCTAssertEqual(timeoutResolverMock.challengeValueGetCalls, 1)
    }

    /// Прошли проверку challenge
    func test_completed_success() throws {
        allureId(2358075) // Подтверждаем статус проверки, отправляя v2/Submit3dsAuthorizationV2

        // given
        var completionResult: GetPaymentStatePayload?
        let fakedResult = GetPaymentStatePayload.fake()

        try setupStartAppBasedFlow()
        sut.completionHandler = { result in
            completionResult = try? result.get()
        }

        let completionEvent = CompletionEvent(sdkTransactionID: "", transactionStatus: "")
        acquiringThreeDSServiceMock.submit3DSAuthorizationV2ReturnValue = EmptyCancellable()
        acquiringThreeDSServiceMock.submit3DSAuthorizationV2CompletionClosureInput = .success(fakedResult)

        // when
        sut.completed(completionEvent)

        // then
        let result = try XCTUnwrap(completionResult)
        XCTAssertEqual(result, fakedResult)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
        XCTAssertEqual(acquiringThreeDSServiceMock.submit3DSAuthorizationV2CallsCount, 1)
    }

    func test_cancelled() throws {
        // given
        var didCallCancellation = false
        sut.cancelHandler = { didCallCancellation = true }
        try setupStartAppBasedFlow()

        // when
        sut.cancelled()

        // then
        XCTAssertTrue(didCallCancellation)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_timedout() throws {
        // given

        // when
        sut.timedout()

        // then
    }

    func test_protocolError() throws {
        // given
        try setupStartAppBasedFlow()
        let protocolError = ProtocolErrorEvent.fake()
        var receivedError: Error?
        sut.completionHandler = { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
        }

        // when
        sut.protocolError(protocolError)

        // then
        let value = try XCTUnwrap(receivedError as? NSError)
        XCTAssertEqual(value.domain, .doesntMatter)
        XCTAssertTrue(value.code > 0)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_runtimeError() throws {
        // given
        try setupStartAppBasedFlow()
        var receivedError: Error?
        sut.completionHandler = { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
        }

        let runtimeError = RuntimeErrorEvent(errorCode: .doesntMatter, errorMessage: .doesntMatter)

        // when
        sut.runtimeError(runtimeError)

        // then
        let value = try XCTUnwrap(receivedError as? NSError)
        XCTAssertEqual(value.domain, .doesntMatter)
        XCTAssertTrue(value.code > 0)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }
}

extension TDSControllerTests {

    @discardableResult
    func setupStartAppBasedFlow() throws -> AuthenticationRequestParameters {
        // given
        transactionMock.getAuthenticationRequestParametersReturnValue = .fake()
        transactionMock.getProgressViewReturnValue = .fake()

        // when
        let authParams = try sut.startAppBasedFlow(
            directoryServerID: .doesntMatter,
            messageVersion: .doesntMatter
        )

        return authParams
    }
}

private extension String {
    static let doesntMatter = "doesntMatter"
}

private extension ProtocolErrorEvent {

    static func fake() -> ProtocolErrorEvent {
        ProtocolErrorEvent(
            sdkTransactionID: .doesntMatter,
            errorMessage: ErrorMessage(
                errorCode: .doesntMatter,
                errorDescription: .doesntMatter,
                errorDetails: .doesntMatter,
                transactionID: .doesntMatter
            )
        )
    }
}
