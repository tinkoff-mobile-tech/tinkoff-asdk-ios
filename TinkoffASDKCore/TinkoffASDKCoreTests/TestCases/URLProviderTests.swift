//
//  URLProviderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 25.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class URLProviderTests: XCTestCase {
    func test_buildURL() {
        // given
        let provider = URLProvider(host: .host)

        // when
        let url = provider?.url

        // then
        XCTAssertEqual(url?.absoluteString, "https://\(String.host)")
    }

    func test_buildURL_whenHostIsInvalid() {
        // given
        let provider = URLProvider(host: .invalidHost)

        // when
        let url = provider?.url

        // then
        XCTAssertNil(url)
    }
}

// MARK: Constants

private extension String {
    static let host = "host"
    static let invalidHost = "хост"
}
