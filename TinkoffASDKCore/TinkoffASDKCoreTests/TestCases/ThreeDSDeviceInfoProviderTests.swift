//
//  ThreeDSDeviceInfoProviderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ThreeDSDeviceInfoProviderTests: XCTestCase {
    // MARK: Properties

    private var sdkUiProviderMock: AppBasedSdkUiProviderMock!
    private var urlBuilderMock: ThreeDSURLBuilderMock!
    private var languageProviderMock: LanguageProviderMock!
    private var sut: ThreeDSDeviceInfoProvider!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        urlBuilderMock = ThreeDSURLBuilderMock()
        sdkUiProviderMock = AppBasedSdkUiProviderMock()
        languageProviderMock = LanguageProviderMock()
        sut = ThreeDSDeviceInfoProvider(
            languageProvider: languageProviderMock,
            urlBuilder: urlBuilderMock,
            sdkUiProvider: sdkUiProviderMock
        )
    }

    override func tearDown() {
        sdkUiProviderMock = nil
        urlBuilderMock = nil
        languageProviderMock = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_build() {
        // given
        let lang = AcquiringSdkLanguage.ru
        languageProviderMock.language = lang
        urlBuilderMock.urlReturnValue = .doesNotMatter
        sdkUiProviderMock.sdkInterfaceReturnValue = .native
        sdkUiProviderMock.sdkUiTypesReturnValue = [.html]

        // when
        let info = sut.createThreeDsDataBrowser(threeDSCompInd: .threeDSCompInd)

        // then
        XCTAssertEqual(info.threeDSCompInd, .threeDSCompInd)
        XCTAssertEqual(info.javaEnabled, "true")
        XCTAssertEqual(info.colorDepth, "32")
        XCTAssertEqual(info.language, lang.rawValue)
        XCTAssertEqual(info.timezone, "\(TimeZone.current.secondsFromGMT() / 60)")
        XCTAssertEqual(info.screenHeight, "\(Int(UIScreen.main.bounds.height * UIScreen.main.scale))")
        XCTAssertEqual(info.screenWidth, "\(Int(UIScreen.main.bounds.width * UIScreen.main.scale))")
        XCTAssertEqual(info.cresCallbackUrl, "https://www.tinkoff.ru")

        XCTAssertEqual(
            urlBuilderMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.confirmation3DSTerminationV2URL.rawValue
        )
    }

    func test_build_whenLanguageIsNil() {
        // given
        urlBuilderMock.urlReturnValue = .doesNotMatter
        sdkUiProviderMock.sdkInterfaceReturnValue = .native
        sdkUiProviderMock.sdkUiTypesReturnValue = [.html]

        // when
        let info = sut.createThreeDsDataBrowser(threeDSCompInd: .threeDSCompInd)

        // then
        XCTAssertEqual(info.language, AcquiringSdkLanguage.ru.rawValue)
    }

    func test_createThreeDsDataBrowser() {
        // given
        urlBuilderMock.urlReturnValue = .doesNotMatter
        sdkUiProviderMock.sdkInterfaceReturnValue = .native
        sdkUiProviderMock.sdkUiTypesReturnValue = [.html]

        // when
        let info = sut.createThreeDsDataBrowser()

        // then
        XCTAssertEqual(info.threeDSCompInd, "Y")
    }
}

// MARK: - Constants

private extension String {
    static let threeDSCompInd = "threeDSCompInd"
}
