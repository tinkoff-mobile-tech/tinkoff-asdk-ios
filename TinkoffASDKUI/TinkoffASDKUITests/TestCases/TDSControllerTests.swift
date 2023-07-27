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

    var acquiringThreeDSServiceMock: AcquiringThreeDSServiceMock!
    var tDSWrapperMock: TDSWrapperMock!
    var timeoutResolverMock: TimeoutResolverMock!
    var transactionMock: TransactionMock!
    var tdsCertsManagerMock: TDSCertsManagerMock!
    var threeDSDeviceInfoProviderMock: ThreeDSDeviceInfoProviderMock!
    var delayExecutorMock: DelayedExecutorMock!
    var mainQueueMock: DispatchQueueMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        acquiringThreeDSServiceMock = AcquiringThreeDSServiceMock()
        tDSWrapperMock = TDSWrapperMock()
        timeoutResolverMock = TimeoutResolverMock()
        transactionMock = TransactionMock()
        tdsCertsManagerMock = TDSCertsManagerMock()
        threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()
        delayExecutorMock = DelayedExecutorMock()
        mainQueueMock = DispatchQueueMock()
        delayExecutorMock.executeWorkShouldExecute = true
        DispatchQueueMock.performOnMainBlockShouldExecute = true

        tDSWrapperMock.createTransactionReturnValue = transactionMock

        sut = TDSController(
            threeDsService: acquiringThreeDSServiceMock,
            tdsWrapper: tDSWrapperMock,
            tdsTimeoutResolver: timeoutResolverMock,
            tdsCertsManager: tdsCertsManagerMock,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProviderMock,
            delayExecutor: delayExecutorMock,
            mainQueue: mainQueueMock
        )
    }

    override func tearDown() {
        delayExecutorMock.executeWorkShouldExecute = false
        DispatchQueueMock.performOnMainBlockShouldExecute = false

        acquiringThreeDSServiceMock = nil
        tDSWrapperMock = nil
        timeoutResolverMock = nil
        transactionMock = nil
        tdsCertsManagerMock = nil
        threeDSDeviceInfoProviderMock = nil
        delayExecutorMock = nil
        mainQueueMock = nil

        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_startAppBasedFlow_happy_path() throws {
        // given
        mainQueueMock.asyncWorkShouldExecute = true

        transactionMock.getAuthenticationRequestParametersReturnValue = .fake()
        transactionMock.getProgressViewReturnValue = ProgressDialogMock()
        var didReceiveThreeDSInfo = false

        // when
        setupAndStartAppBasedFlow { result in
            switch result {
            case .success: didReceiveThreeDSInfo = true
            case .failure: break
            }
        }

        // then
        XCTAssertEqual(transactionMock.getAuthenticationRequestParametersCallsCount, 1)
        XCTAssertEqual(transactionMock.getProgressViewCallsCount, 1)
        XCTAssertEqual(mainQueueMock.asyncCallsCount, 1)
        XCTAssertTrue(didReceiveThreeDSInfo)
    }

    func test_doChallenge() throws {
        allureId(2358075)
        // given
        setupAndStartAppBasedFlow()
        timeoutResolverMock.underlyingChallengeValue = 1

        // when
        sut.doChallenge(with: .fake())

        // then
        XCTAssertEqual(transactionMock.doChallengeCallsCount, 1)
    }

    /// Прошли проверку challenge
    func test_completed_success() throws {
        allureId(2358075) // Подтверждаем статус проверки, отправляя v2/Submit3dsAuthorizationV2

        // given
        var completionResult: GetPaymentStatePayload?
        let fakedResult = GetPaymentStatePayload.fake()

        setupAndStartAppBasedFlow()
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

    func test_completed_with_doChallenge_success() throws {
        // given
        let fakedResult = GetPaymentStatePayload.fake()

        setupAndStartAppBasedFlow()
        timeoutResolverMock.underlyingChallengeValue = 1
        sut.doChallenge(with: .fake())

        let completionEvent = CompletionEvent(sdkTransactionID: "", transactionStatus: "")
        acquiringThreeDSServiceMock.submit3DSAuthorizationV2ReturnValue = EmptyCancellable()
        acquiringThreeDSServiceMock.submit3DSAuthorizationV2CompletionClosureInput = .success(fakedResult)

        // when
        sut.completed(completionEvent)

        // then
        XCTAssertEqual(acquiringThreeDSServiceMock.submit3DSAuthorizationV2CallsCount, 1)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
        XCTAssertEqual(acquiringThreeDSServiceMock.submit3DSAuthorizationV2CallsCount, 1)
    }

    func test_cancelled() throws {
        // given
        var didCallCancellation = false
        sut.cancelHandler = { didCallCancellation = true }
        setupAndStartAppBasedFlow()

        // when
        sut.cancelled()

        // then
        XCTAssertTrue(didCallCancellation)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_timedout() throws {
        // given
        setupAndStartAppBasedFlow()
        var receivedTimeoutError = false

        sut.completionHandler = { result in
            switch result {
            case let .failure(error as TDSFlowError):
                receivedTimeoutError = error == .timeout
            default: break
            }
        }

        // when
        sut.timedout()

        // then
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
        XCTAssertTrue(receivedTimeoutError)
    }

    func test_protocolError() throws {
        // given
        setupAndStartAppBasedFlow()
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
        XCTAssertEqual(value.domain, .fake)
        XCTAssertTrue(value.code > 0)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_runtimeError() throws {
        // given
        setupAndStartAppBasedFlow()
        var receivedError: Error?
        sut.completionHandler = { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
        }

        let runtimeError = RuntimeErrorEvent(errorCode: .fake, errorMessage: .fake)

        // when
        sut.runtimeError(runtimeError)

        // then
        let value = try XCTUnwrap(receivedError as? NSError)
        XCTAssertEqual(value.domain, .fake)
        XCTAssertTrue(value.code > 0)
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_stop() {
        // given
        setupAndStartAppBasedFlow()

        // when
        sut.stop()

        // then
        XCTAssertEqual(transactionMock.closeCallsCount, 1)
    }

    func test_startAppBasedFlow_returnsError() {
        // when
        var result: Result<ThreeDSDeviceInfo, Error>?
        sut.startAppBasedFlow(check3dsPayload: .fake(version: .v1), completion: { result = $0 })

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(error.localizedDescription, "Couldn't retrieve paymentSystem")
        } else {
            XCTFail()
        }
    }

    func test_throwError() {
        // given
        let errorStub = ErrorStub()
        transactionMock.getAuthenticationRequestParametersThrowableError = errorStub

        // when
        var result: Result<ThreeDSDeviceInfo, Error>?
        setupAndStartAppBasedFlow { result = $0 }

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(errorStub as NSError, error as NSError)
        } else {
            XCTFail()
        }
    }
}

extension TDSControllerTests {

    func setupAndStartAppBasedFlow(completion: ((Result<ThreeDSDeviceInfo, Error>) -> Void)? = nil) {
        // given
        transactionMock.getAuthenticationRequestParametersReturnValue = .fake()
        transactionMock.getProgressViewReturnValue = ProgressDialogMock()
        tdsCertsManagerMock.checkAndUpdateCertsIfNeededCompletionClosureInput = .success("matchingDirectoryServerID")
        // when
        sut.startAppBasedFlow(
            check3dsPayload: .fake(version: .appBased),
            completion: completion ?? { _ in }
        )
    }
}
