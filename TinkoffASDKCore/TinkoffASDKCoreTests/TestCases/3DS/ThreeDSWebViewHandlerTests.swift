//
//  ThreeDSWebViewHandlerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 31.03.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ThreeDSWebViewHandlerTests: BaseTestCase {

    var sut: ThreeDSWebViewHandler!

    // Mocks

    var threeDSURLBuilderMock: ThreeDSURLBuilderMock!
    var acquiringDecoderMock: AcquiringDecoderMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        threeDSURLBuilderMock = ThreeDSURLBuilderMock()
        acquiringDecoderMock = AcquiringDecoderMock()
        sut = ThreeDSWebViewHandler(urlBuilder: threeDSURLBuilderMock, decoder: acquiringDecoderMock)
    }

    override func tearDown() {
        threeDSURLBuilderMock = nil
        acquiringDecoderMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_handle_returns_cancel() {
        allureId(2397499, "Успешно обрабатываем отмену в случае статуса отмены web-view")

        // when
        var returnedCancell = false
        let result: ThreeDSWebViewHandlingResult<GetAddCardStatePayload>? = sut.handle(
            urlString: "cancel.do",
            responseData: Data()
        )

        // then
        if case .cancelled = result { returnedCancell = true }
        XCTAssertTrue(returnedCancell)
    }

    func test_handle_returns_error() {
        allureId(2397498, "Успешно обрабатываем ошибку в случае ошибки web-view")
        // given

        threeDSURLBuilderMock.urlReturnValue = .doesNotMatter
        acquiringDecoderMock.decodeThrowableError = ErrorStub()

        // when
        var returnedError = false
        let result: ThreeDSWebViewHandlingResult<GetAddCardStatePayload>? = sut.handle(
            urlString: URL.doesNotMatter.absoluteString,
            responseData: Data()
        )

        // then
        if case let .failed(givenError) = result, givenError is ErrorStub {
            returnedError = true
        }

        XCTAssertEqual(acquiringDecoderMock.decodeCallsCount, 0)
        XCTAssertTrue(returnedError)
    }
}
