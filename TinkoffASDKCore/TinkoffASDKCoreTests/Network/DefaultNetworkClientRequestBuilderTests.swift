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
    
    func testBuilderSetHeadersFromRequest() {
        let headers = ["headerKey": "headerValue"]
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .get,
                                          headers: headers)
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL, request: request, requestAdapter: nil)
            XCTAssertNotNil(urlRequest.url?.absoluteString, "URLRequest's url can't be nil")
            XCTAssertEqual(headers, urlRequest.allHTTPHeaderFields)
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
    
    func testJSONParametersEncodingSetCorrectContentTypeIfNotSetBefore() {
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
            
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
            
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testJSONParametersEncodingDoesntSetContentTypeIfSetBefore() {
        let parameters: [String: Any] = ["param1": true, "param2": "value2", "param3": 10]
        
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post,
                                          parameters: parameters,
                                          headers: ["Content-Type": "anything"])
        
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL,
                                                         request: request,
                                                         requestAdapter: nil)
            XCTAssertNotNil(urlRequest.httpBody, "urlRequest's httpBody can't be nil")
            
            let urlRequestBodyJSON = try? JSONSerialization.jsonObject(with: urlRequest.httpBody!,
                                                                       options: []) as? [String: Any]
            XCTAssertNotNil(urlRequestBodyJSON, "JSON from urlRequest's httpBody can't be nil")
            
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "anything")
            
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testBuilderCallsNetworkRequestAdapterParametersAndHeadersMethod() {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post)
        
        do {
            _ = try builder.buildURLRequest(baseURL: baseURL,
                                        request: request,
                                        requestAdapter: mockRequestAdapter)
            
            XCTAssertTrue(mockRequestAdapter.isAdditionalHeadersMethodCalled,
                          "additionalHeaders(for request: NetworkRequest) method must be called")
            XCTAssertTrue(mockRequestAdapter.isAdditionalParametersMethodCalled,
                          "additionalParameters(for request: NetworkRequest) method must be called")
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testBuilderAddAdditinalHeadersToEmptyRequestHeadersFromNetworkRequestAdapter() {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalHeaders = ["headerKey1": "headerValue1",
                                 "headerKey2": "headerValue2"]
        mockRequestAdapter.additionalHeaders = additionalHeaders
        
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post)
        
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL,
                                                         request: request,
                                                         requestAdapter: mockRequestAdapter)
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, additionalHeaders)
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testBuilderAddAdditinalHeadersToRequestHeadersFromNetworkRequestAdapter() {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalHeaders = ["headerKey1": "headerValue1",
                                 "headerKey2": "headerValue2"]
        mockRequestAdapter.additionalHeaders = additionalHeaders
        
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post,
                                          parameters: ["param1Key": "param1Value"],
                                          headers: ["headerKey3": "headerValue3"])
        
        let resultHeaders = ["headerKey1": "headerValue1",
                             "headerKey2": "headerValue2",
                             "headerKey3": "headerValue3",
                             "Content-Type": "application/json"]
        
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL,
                                                         request: request,
                                                         requestAdapter: mockRequestAdapter)
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, resultHeaders)
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
    
    func testBuilderAddAdditinalParametersToRequestFromNetworkRequestAdapter() {
        let mockRequestAdapter = MockNetworkRequestAdapter()
        let additionalParameters: HTTPParameters = ["additionalParamKey1": "additionalParamValue1",
                                                    "additionalParamKey2": false]
        mockRequestAdapter.additionalParameters = additionalParameters
        
        let parameters: HTTPParameters = ["param1": true, "param2": "value2", "param3": 10]
        let request = TestsNetworkRequest(path: ["test"],
                                          httpMethod: .post,
                                          parameters: parameters)
        
        let resultParameters: HTTPParameters = [
            "param1": true,
            "param2": "value2",
            "param3": 10,
            "additionalParamKey1": "additionalParamValue1",
            "additionalParamKey2": false
        ]
        
        do {
            let urlRequest = try builder.buildURLRequest(baseURL: baseURL,
                                                         request: request,
                                                         requestAdapter: mockRequestAdapter)
            XCTAssertNotNil(urlRequest.httpBody, "urlRequest's httpBody can't be nil")
            
            let urlRequestBodyJSON = try? JSONSerialization.jsonObject(with: urlRequest.httpBody!,
                                                                       options: []) as? [String: Any]
            XCTAssertNotNil(urlRequestBodyJSON, "JSON from urlRequest's httpBody can't be nil")
            
            XCTAssertEqual(NSDictionary(dictionary: urlRequestBodyJSON!),
                           NSDictionary(dictionary: resultParameters))
        } catch {
            XCTFail("URLRequest build failed with: \(error)")
        }
    }
}
