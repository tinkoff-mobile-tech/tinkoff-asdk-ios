//
//  ThreeDSURLBuilderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 20.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ThreeDSURLBuilderTests: XCTestCase {
    // MARK: Properties

    private var baseURLProviderMock: URLProviderMock!
    private var sut: ThreeDSURLBuilder!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        baseURLProviderMock = URLProviderMock()
        sut = ThreeDSURLBuilder(baseURLProvider: baseURLProviderMock)
    }

    override func tearDown() {
        baseURLProviderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatBuilderBuildsURL_whenTypeIsThreeDSCheckNotificationURL() {
        // given
        baseURLProviderMock.underlyingUrl = .doesNotMatter

        // when
        let url = sut.url(ofType: .threeDSCheckNotificationURL)

        // then
        XCTAssertEqual(
            url.absoluteString,
            URL.doesNotMatter.appendingPathComponent(ThreeDSURLType.threeDSCheckNotificationURL.rawValue).absoluteString
        )
    }

    func test_thatBuilderBuildsURL_whenTypeIsConfirmation3DSTerminationURL() {
        // given
        baseURLProviderMock.underlyingUrl = .doesNotMatter

        // when
        let url = sut.url(ofType: .confirmation3DSTerminationURL)

        // then
        XCTAssertEqual(
            url.absoluteString,
            URL.doesNotMatter.appendingPathComponent(ThreeDSURLType.confirmation3DSTerminationURL.rawValue).absoluteString
        )
    }

    func test_thatBuilderBuildsURL_whenTypeIsConfirmation3DSTerminationV2URL() {
        // given
        baseURLProviderMock.underlyingUrl = .doesNotMatter

        // when
        let url = sut.url(ofType: .confirmation3DSTerminationV2URL)

        // then
        XCTAssertEqual(
            url.absoluteString,
            URL.doesNotMatter.appendingPathComponent(ThreeDSURLType.confirmation3DSTerminationV2URL.rawValue).absoluteString
        )
    }
}
