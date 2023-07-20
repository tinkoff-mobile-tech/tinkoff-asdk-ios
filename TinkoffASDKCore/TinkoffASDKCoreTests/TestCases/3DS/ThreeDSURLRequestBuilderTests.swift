//
//  ThreeDSURLRequestBuilderTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import Foundation
import XCTest

@testable import TinkoffASDKCore

extension String {
    static let expectedUserAgent = "iPhone 13 Pro Max/iOS/15.0/TinkoffAcquiringSDK"
}

final class ThreeDSURLRequestBuilderTests: BaseTestCase {

    var sut: ThreeDSURLRequestBuilder!

    // Mocks
    var deviceInfoProviderMock: DeviceInfoProviderMock!
    var urlBuilderMock: ThreeDSURLBuilderMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        deviceInfoProviderMock = DeviceInfoProviderMock()
        urlBuilderMock = ThreeDSURLBuilderMock()

        sut = ThreeDSURLRequestBuilder(
            urlBuilder: urlBuilderMock,
            deviceInfoProvider: deviceInfoProviderMock
        )
    }

    override func tearDown() {
        deviceInfoProviderMock = nil
        urlBuilderMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_buildConfirmation3DSRequest() throws {
        allureId(2397514, "Инициалилизируем 3DS web-view v1 по ответу v2/AttachCard")
        allureId(2358058) // Редиректим на ACSUrl

        // given
        let data = Confirmation3DSData.fake()
        urlBuilderMock.urlReturnValue = URL(string: ThreeDSURLType.confirmation3DSTerminationURL.rawValue)!

        // when
        let urlRequest = try? sut.buildConfirmation3DSRequest(requestData: data)

        // then
        let request = try XCTUnwrap(urlRequest)
        XCTAssertEqual(request.url?.absoluteString, data.acsUrl)
        XCTAssertEqual(urlBuilderMock.urlCallsCount, 1)
        XCTAssertEqual(urlBuilderMock.urlReceivedArguments?.rawValue, ThreeDSURLType.confirmation3DSTerminationURL.rawValue)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), String.expectedUserAgent)
    }

    func test_buildConfirmation3DSACSRequest() throws {
        allureId(2397494, "Инициалилизируем 3DS web-view v2 по ответу v2/AttachCard")

        // given
        let data = Confirmation3DSDataACS.fake()

        // when
        let urlRequest = try? sut.buildConfirmation3DSRequestACS(requestData: data, version: "2.0")

        // then
        let request = try XCTUnwrap(urlRequest)
        XCTAssertEqual(request.url?.absoluteString, data.acsUrl)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), String.expectedUserAgent)
    }

    func test_build3DSCheckURLRequest() throws {
        // given
        let data = Checking3DSURLData.fake()
        urlBuilderMock.urlReturnValue = .doesNotMatter

        // when
        let urlRequest = try? sut.build3DSCheckURLRequest(requestData: data)

        // then
        let request = try XCTUnwrap(urlRequest)
        XCTAssertEqual(request.url?.absoluteString, data.threeDSMethodURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), String.expectedUserAgent)
    }

    func test_build3DSCheckURLRequest_failed() throws {
        // given
        let data = Checking3DSURLData.fake(threeDSMethodURL: .invalidURL)
        urlBuilderMock.urlReturnValue = .doesNotMatter

        // when
        var urlRequest: URLRequest?
        var err: Error?

        do {
            urlRequest = try sut.build3DSCheckURLRequest(requestData: data)
        } catch {
            err = error
        }

        // then
        XCTAssertNil(urlRequest)
        XCTAssertNotNil(err)
    }

    func test_buildConfirmation3DSACSRequest_failed() throws {
        // given
        var data = Confirmation3DSDataACS.fake()
        data.acsUrl = .invalidURL
        urlBuilderMock.urlReturnValue = .doesNotMatter

        // when
        var urlRequest: URLRequest?
        var err: Error?

        do {
            urlRequest = try sut.buildConfirmation3DSRequestACS(requestData: data, version: "")
        } catch {
            err = error
        }

        // then
        XCTAssertNil(urlRequest)
        XCTAssertNotNil(err)
    }

    func test_buildConfirmation3DSRequestACS_failed() throws {
        // given
        var data = Confirmation3DSDataACS.fake()
        data.acsUrl = .invalidURL
        urlBuilderMock.urlReturnValue = .doesNotMatter

        // when
        var urlRequest: URLRequest?
        var err: Error?

        do {
            urlRequest = try sut.buildConfirmation3DSRequestACS(requestData: data, version: "")
        } catch {
            err = error
        }

        // then
        XCTAssertNil(urlRequest)
        XCTAssertNotNil(err)
    }

    func test_buildConfirmation3DSRequest_failed() throws {
        // given
        var data = Confirmation3DSData.fake()
        data.acsUrl = .invalidURL
        urlBuilderMock.urlReturnValue = .doesNotMatter

        // when
        var urlRequest: URLRequest?
        var err: Error?

        do {
            urlRequest = try sut.buildConfirmation3DSRequest(requestData: data)
        } catch {
            err = error
        }

        // then
        XCTAssertNil(urlRequest)
        XCTAssertNotNil(err)
    }
}

// MARK: Constants

private extension String {
    static let invalidURL = ""
}
