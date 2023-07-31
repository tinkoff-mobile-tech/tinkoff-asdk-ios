//
//  ThreeDSFacade.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ThreeDSFacadeTests: XCTestCase {
    // MARK: Properties

    private var sut: ThreeDSFacade!

    private var threeDSURLBuilderMock: ThreeDSURLBuilderMock!
    private var threeDSURLRequestBuilderMock: ThreeDSURLRequestBuilderMock!
    private var webViewHandlerBuilderMock: ThreeDSWebViewHandlerBuilderMock!
    private var deviceParamsProviderBuilderBuilderMock: ThreeDSDeviceParamsProviderBuilderMock!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        threeDSURLBuilderMock = ThreeDSURLBuilderMock()
        threeDSURLRequestBuilderMock = ThreeDSURLRequestBuilderMock()
        webViewHandlerBuilderMock = ThreeDSWebViewHandlerBuilderMock()
        deviceParamsProviderBuilderBuilderMock = ThreeDSDeviceParamsProviderBuilderMock()
        sut = ThreeDSFacade(
            threeDSURLBuilder: threeDSURLBuilderMock,
            threeDSURLRequestBuilder: threeDSURLRequestBuilderMock,
            webViewHandlerBuilder: webViewHandlerBuilderMock,
            deviceParamsProviderBuilder: deviceParamsProviderBuilderBuilderMock
        )
    }

    override func tearDown() {
        threeDSURLBuilderMock = nil
        threeDSURLRequestBuilderMock = nil
        webViewHandlerBuilderMock = nil
        deviceParamsProviderBuilderBuilderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_build3DSCheckURLRequest() throws {
        // given
        let requestMock = URLRequest(url: .doesNotMatter)
        threeDSURLRequestBuilderMock.build3DSCheckURLRequestReturnValue = requestMock

        // when
        let request = try sut.build3DSCheckURLRequest(requestData: .fake())

        // then
        XCTAssertEqual(request, requestMock)
    }

    func test_buildConfirmation3DSRequest() throws {
        // given
        let requestMock = URLRequest(url: .doesNotMatter)
        threeDSURLRequestBuilderMock.buildConfirmation3DSRequestReturnValue = requestMock

        // when
        let request = try sut.buildConfirmation3DSRequest(requestData: .fake())

        // then
        XCTAssertEqual(request, requestMock)
    }

    func test_buildConfirmation3DSRequestACS() throws {
        // given
        let requestMock = URLRequest(url: .doesNotMatter)
        threeDSURLRequestBuilderMock.buildConfirmation3DSRequestACSReturnValue = requestMock

        // when
        let request = try sut.buildConfirmation3DSRequestACS(requestData: .fake(), version: "2.0")

        // then
        XCTAssertEqual(request, requestMock)
    }

    func test_url_confirmation3DSTerminationURL() {
        // given
        threeDSURLBuilderMock.urlReturnValue = .doesNotMatter

        // when
        _ = sut.url(ofType: .confirmation3DSTerminationURL)

        // when
        XCTAssertEqual(threeDSURLBuilderMock.urlCallsCount, 1)
        XCTAssertEqual(
            threeDSURLBuilderMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.confirmation3DSTerminationURL.rawValue
        )
    }

    func test_url_confirmation3DSTerminationV2URL() {
        // given
        threeDSURLBuilderMock.urlReturnValue = .doesNotMatter

        // when
        _ = sut.url(ofType: .confirmation3DSTerminationV2URL)

        // when
        XCTAssertEqual(threeDSURLBuilderMock.urlCallsCount, 1)
        XCTAssertEqual(
            threeDSURLBuilderMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.confirmation3DSTerminationV2URL.rawValue
        )
    }

    func test_url_threeDSCheckNotificationURL() {
        // given
        threeDSURLBuilderMock.urlReturnValue = .doesNotMatter

        // when
        _ = sut.url(ofType: .threeDSCheckNotificationURL)

        // when
        XCTAssertEqual(threeDSURLBuilderMock.urlCallsCount, 1)
        XCTAssertEqual(
            threeDSURLBuilderMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.threeDSCheckNotificationURL.rawValue
        )
    }

    func test_threeDSWebViewHandler() {
        // given
        webViewHandlerBuilderMock.threeDSWebViewHandlerReturnValue = ThreeDSWebViewHandlerStub()

        // when
        _ = sut.threeDSWebViewHandler()

        // then
        XCTAssertEqual(webViewHandlerBuilderMock.threeDSWebViewHandlerCallsCount, 1)
    }

    func test_threeDSDeviceInfoProvider() {
        // given
        deviceParamsProviderBuilderBuilderMock.threeDSDeviceInfoProviderReturnValue = ThreeDSDeviceInfoProviderMock()

        // when
        _ = sut.threeDSDeviceInfoProvider()

        // then
        XCTAssertEqual(deviceParamsProviderBuilderBuilderMock.threeDSDeviceInfoProviderCallsCount, 1)
    }
}
