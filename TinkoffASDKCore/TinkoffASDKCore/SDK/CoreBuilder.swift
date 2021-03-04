//
//
//  CoreBuilder.swift
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


import Foundation

struct CoreBuilder {
    
    private let configuration: AcquiringSdkConfiguration
    
    init(configuration: AcquiringSdkConfiguration) {
        self.configuration = configuration
    }
    
    func buildAPI() -> API {
        return AcquiringAPI(networkClient: buildNetworkClient(
                                requestAdapter: buildAPIParametersProvider(terminalKey: configuration.credential.terminalKey,
                                                                           password: configuration.credential.password)),
                            apiResponseDecoder: buildAPIResponseDecoder())
    }
    
    func cardDataFormatter() -> CardDataFormatter {
        return CardDataFormatter()
    }
    
    func ipAddressProvider() -> IPAddressProvider {
        return IPAddressProvider(factory: IPAddressFactory())
    }
    
    func threeDSURLBuilder() -> ThreeDSURLBuilder {
        return ThreeDSURLBuilder(apiHostProvider: buildAPIHostProvider())
    }
    
    func threeDSURLRequestBuilder() -> ThreeDSURLRequestBuilder {
        return ThreeDSURLRequestBuilder(threeDSURLBuilder: threeDSURLBuilder(),
                                        deviceInfoProvider: deviceInfoProvider())
    }
    
    func deviceInfoProvider() -> DeviceInfoProvider {
        return DefaultDeviceInfoProvider()
    }
}

private extension CoreBuilder {
    func buildNetworkClient(requestAdapter: NetworkRequestAdapter) -> NetworkClient {
        let networkClient = DefaultNetworkClient(urlRequestPerfomer: buildURLSession(),
                                                 hostProvider: buildAPIHostProvider(),
                                                 requestBuilder: buildRequestBuilder(),
                                                 responseValidator: buildResponseValidator())
        networkClient.requestAdapter = requestAdapter
        return networkClient
    }
    
    func buildURLSession() -> URLSession {
        return URLSession(configuration: buildURLSessionConfiguration(requestsTimeoutInterval: configuration.requestsTimeoutInterval))
    }
    
    func buildURLSessionConfiguration(requestsTimeoutInterval: TimeInterval) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestsTimeoutInterval
        configuration.timeoutIntervalForResource = requestsTimeoutInterval
        return configuration
    }
    
    func buildRequestBuilder() -> NetworkClientRequestBuilder {
        return DefaultNetworkClientRequestBuilder()
    }
    
    func buildResponseValidator() -> HTTPURLResponseValidator {
        return DefaultHTTPURLResponseValidator()
    }
    
    func buildAPIURLBuilder() -> APIURLBuilder {
        return APIURLBuilder()
    }
    
    func buildAPIHostProvider() -> APIHostProvider {
        return APIHostProvider(sdkEnvironmentProvider: configuration.serverEnvironment,
                               apiURLBuilder: buildAPIURLBuilder())
    }
    
    func buildAPIParametersProvider(terminalKey: String,
                                    password: String) -> APIParametersProvider {
        return APIParametersProvider(terminalKey: terminalKey,
                                     tokenBuilder: buildAPITokenBuilder(password: password))
    }
    
    func buildAPITokenBuilder(password: String) -> APITokenBuilder {
        return AcquiringTokenBuilder(password: password)
    }
    
    func buildAPIResponseDecoder() -> APIResponseDecoder {
        return AcquiringAPIResponseDecoder(decoder: buildJSONDecoder())
    }
    
    func buildJSONDecoder() -> JSONDecoder {
        return JSONDecoder()
    }

}
