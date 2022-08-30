//
//
//  DefaultHTTPURLResponseValidatorTests.swift
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

class DefaultHTTPURLResponseValidatorTests: XCTestCase {
    
    let url = URL(string: "https://tinkoff.ru")!
    let httpVersion = "HTTP/1.1"
    
    let validator = DefaultHTTPURLResponseValidator()
    
    func testValidIfStatusCode200() throws {
        let response = HTTPURLResponse(url: url,
                                       statusCode: 200,
                                       httpVersion: httpVersion,
                                       headerFields: nil)!
        
        XCTAssertNoThrow(try validator.validate(response: response).get())
    }
    
    func testValidIfStatusCode250() throws {
        let response = HTTPURLResponse(url: url,
                                       statusCode: 250,
                                       httpVersion: httpVersion,
                                       headerFields: nil)!
        
        XCTAssertNoThrow(try validator.validate(response: response).get())
    }
    
    func testValidIfStatusCode299() throws {
        let response = HTTPURLResponse(url: url,
                                       statusCode: 299,
                                       httpVersion: httpVersion,
                                       headerFields: nil)!
        
        XCTAssertNoThrow(try validator.validate(response: response).get())
    }
    
    func testInvalidIfStatusCode400() throws {
        let response = HTTPURLResponse(url: url,
                                       statusCode: 400,
                                       httpVersion: httpVersion,
                                       headerFields: nil)!
        
        XCTAssertThrowsError(try validator.validate(response: response).get(), "") { error in
            guard let defaultHTTPURLResponseValidatorError = error as? DefaultHTTPURLResponseValidator.Error,
                  defaultHTTPURLResponseValidatorError == .failedStatusCode else {
                XCTFail("response with 400 status code must produce error DefaultHTTPURLResponseValidator.failedStatusCode")
                return
            }
        }
    }
    
    func testInvalidIfStatusCode500() throws {
        let response = HTTPURLResponse(url: url,
                                       statusCode: 400,
                                       httpVersion: httpVersion,
                                       headerFields: nil)!
        
        XCTAssertThrowsError(try validator.validate(response: response).get(), "") { error in
            guard let defaultHTTPURLResponseValidatorError = error as? DefaultHTTPURLResponseValidator.Error,
                  defaultHTTPURLResponseValidatorError == .failedStatusCode else {
                XCTFail("response with 400 status code must produce error DefaultHTTPURLResponseValidator.failedStatusCode")
                return
            }
        }
    }
}
