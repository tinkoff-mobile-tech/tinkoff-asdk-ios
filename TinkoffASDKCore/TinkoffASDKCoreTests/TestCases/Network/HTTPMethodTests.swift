//
//  HTTPMethodTests.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 12.05.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class HTTPMethodTests: BaseTestCase {

    // MARK: - Tests

    func test_isAllowedToContainQuery() {
        // given
        let getMethod = HTTPMethod.get
        let postMethod = HTTPMethod.post

        // when
        let getResult = getMethod.isAllowedToContainQuery
        let postResult = postMethod.isAllowedToContainQuery

        // then
        XCTAssertEqual(getResult, true)
        XCTAssertEqual(postResult, false)
    }
}
