//
//  ExternalRequestBuilderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 25.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ExternalRequestBuilderTests: XCTestCase {
    // MARK: Properties

    private var urlProviderMock: URLProviderMock!
    private var sut: ExternalRequestBuilder!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        urlProviderMock = URLProviderMock()
        sut = ExternalRequestBuilder(appBasedConfigURLProvider: urlProviderMock)
    }

    override func tearDown() {
        urlProviderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_get3DSAppBasedConfigRequest() throws {
        // given
        urlProviderMock.underlyingUrl = .doesNotMatter

        // when
        let request = sut.get3DSAppBasedConfigRequest()

        // then
        let configRequest = try (XCTUnwrap(request as? Get3DSAppBasedCertsConfigRequest))
        XCTAssertEqual(configRequest.baseURL.absoluteString, URL.doesNotMatter.absoluteString)
    }

    func test_getSBPBanks() throws {
        // when
        let request = sut.getSBPBanks()

        // then
        let configRequest = try (XCTUnwrap(request as? GetSBPBanksRequest))
        XCTAssertEqual(configRequest.baseURL.absoluteString, "https://qr.nspk.ru")
        XCTAssertEqual(configRequest.httpMethod, .get)
    }
}
