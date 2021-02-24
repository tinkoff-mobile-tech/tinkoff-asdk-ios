//
//
//  APIURLBuilderTests.swift
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

class APIURLBuilderTests: XCTestCase {
    
    let apiUrlBuilder = APIURLBuilder()
        
    func testBuildURLSuccessWithValidHost() {
        let host = "tinkoff.ru"
        
        let expectedUrl = URL(string: "https://\(host)")!
        let resultUrl = try! apiUrlBuilder.buildURL(host: host)
        
        XCTAssertEqual(resultUrl, expectedUrl)
    }
    
    func testBuildURLWithEmptyHostFailWithFailedToBuildAPIUrlError() {
        let host = ""
       
        do {
            _ = try apiUrlBuilder.buildURL(host: host)
            XCTFail()
        } catch APIURLBuilder.Error.failedToBuildAPIUrl {
            
        } catch {
            XCTFail()
        }
    }
}
