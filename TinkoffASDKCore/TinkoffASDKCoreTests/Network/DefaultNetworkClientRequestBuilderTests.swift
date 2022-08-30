//
//
//  DefaultNetworkClientRequestBuilderTests.swift
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

class DefaultNetworkClientRequestBuilderTests: XCTestCase {
    
    let builder = DefaultNetworkClientRequestBuilder()
    let baseURL = URL(string: "https://tinkoff.ru")!
    
    func testNoErrorBuildWithCorrectURLAndPath() {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)
        XCTAssertNoThrow(try builder.buildURLRequest(baseURL: baseURL, request: request, requestAdapter: nil))
    }
    
    func testBuildFailedWithErrorWithEmptyPath() {
        let request = TestsNetworkRequest(path: [], httpMethod: .get)
        XCTAssertThrowsError(try builder.buildURLRequest(baseURL: baseURL, request: request, requestAdapter: nil))
    }

    func testBuildCorrectUrlWithOneItemPath() {
        let request = TestsNetworkRequest(path: ["test"], httpMethod: .get)
        let resultURLString = "https://tinkoff.ru/test"
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL, request: request, requestAdapter: nil)
            XCTAssertNotNil(urlRequest.url?.absoluteString, "URLRequest's url can't be nil")
            XCTAssertEqual(urlRequest.url?.absoluteString, resultURLString)
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testBuildCorrectUrlWithThreeItemsPath() {
        let request = TestsNetworkRequest(path: ["test", "url", "builder"], httpMethod: .get)
        let resultURLString = "https://tinkoff.ru/test/url/builder"
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL, request: request, requestAdapter: nil)
            XCTAssertNotNil(urlRequest.url?.absoluteString, "URLRequest's url can't be nil")
            XCTAssertEqual(urlRequest.url?.absoluteString, resultURLString)
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testJSONParametersEncoding() {
        let parameters: [String: Any] = ["param1": true, "param2": "value2", "param3": 10]
        
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post,
                                          parameters: parameters)
        
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL,
                                                         request: request,
                                                         requestAdapter: nil)
            XCTAssertNotNil(urlRequest.httpBody, "urlRequest's httpBody can't be nil")
            
            let urlRequestBodyJSON = try? JSONSerialization.jsonObject(with: urlRequest.httpBody!,
                                                                       options: []) as? [String: Any]
            XCTAssertNotNil(urlRequestBodyJSON, "JSON from urlRequest's httpBody can't be nil")
            
            XCTAssertEqual(NSDictionary(dictionary: urlRequestBodyJSON!),
                           NSDictionary(dictionary: parameters))
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
}
