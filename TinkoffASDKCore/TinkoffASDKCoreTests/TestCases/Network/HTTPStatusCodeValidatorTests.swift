//
//
//  HTTPStatusCodeValidatorTests.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import TinkoffASDKCore
import XCTest

class HTTPStatusCodeValidatorTests: XCTestCase {
    let sut = HTTPStatusCodeValidator()

    func test_validate_withValidStatusCodesRange_shouldReturnTrue() {
        // given
        let statusCodes = 200 ... 299

        // when
        let allStatusesAreValid = statusCodes.allSatisfy(sut.validate(statusCode:))

        // then
        XCTAssert(allStatusesAreValid)
    }

    func test_validate_withInvalidStatusCodesRange_ShouldReturnFalse() {
        // given
        let statusCodesLessThan200 = Array(-1 ... 199)
        let statusCodesMoreThan299 = Array(300 ... 600)

        // when
        let allStatusCodesAreInvalid = (statusCodesLessThan200 + statusCodesMoreThan299)
            .allSatisfy { !sut.validate(statusCode: $0) }

        // then
        XCTAssert(allStatusCodesAreInvalid)
    }
}
