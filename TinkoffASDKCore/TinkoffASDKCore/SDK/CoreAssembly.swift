//
//
//  CoreAssembly.swift
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

import struct CoreGraphics.CGSize
import Foundation

struct CoreAssembly {
    private let configuration: AcquiringSdkConfiguration
    private let baseURLProvider: BaseURLProvider

    init(configuration: AcquiringSdkConfiguration) throws {
        self.configuration = configuration
        baseURLProvider = try DefaultBaseURLProvider(host: configuration.serverEnvironment.host)
    }

    func buildAPI() -> API {
        AcquiringAPI(
            networkClient: buildNetworkClient(),
            apiResponseDecoder: buildAPIResponseDecoder()
        )
    }

    func cardDataFormatter() -> CardDataFormatter {
        CardDataFormatter()
    }

    func ipAddressProvider() -> IPAddressProvider {
        IPAddressProvider(factory: IPAddressFactory())
    }

    func threeDSURLBuilder() -> ThreeDSURLBuilder {
        ThreeDSURLBuilder(baseURLProvider: baseURLProvider)
    }

    func threeDSURLRequestBuilder() -> ThreeDSURLRequestBuilder {
        ThreeDSURLRequestBuilder(
            threeDSURLBuilder: threeDSURLBuilder(),
            deviceInfoProvider: deviceInfoProvider()
        )
    }

    func deviceInfoProvider() -> DeviceInfoProvider {
        DefaultDeviceInfoProvider()
    }

    func threeDSWebViewHandler<Payload: Decodable>() -> ThreeDSWebViewHandler<Payload> {
        ThreeDSWebViewHandler(
            threeDSURLBuilder: threeDSURLBuilder(),
            jsonDecoder: JSONDecoder()
        )
    }

    func threeDSDeviceParamsProvider(screenSize: CGSize, language: AcquiringSdkLanguage) -> ThreeDSDeviceParamsProvider {
        DefaultThreeDSDeviceParamsProvider(
            screenSize: screenSize,
            language: language,
            threeDSURLBuilder: threeDSURLBuilder()
        )
    }
}

private extension CoreAssembly {
    func buildNetworkClient() -> INetworkClient {
        let networkClient = NetworkClient(
            requestBuilder: buildURLRequestBuilder(),
            urlRequestPerformer: buildURLSession(),
            responseValidator: HTTPURLResponseValidator()
        )

        return networkClient
    }

    func buildURLSession() -> URLSession {
        URLSession(
            configuration: buildURLSessionConfiguration(requestsTimeoutInterval: configuration.requestsTimeoutInterval)
        )
    }

    func buildURLSessionConfiguration(requestsTimeoutInterval: TimeInterval) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestsTimeoutInterval
        configuration.timeoutIntervalForResource = requestsTimeoutInterval
        return configuration
    }

    func buildAPIURLBuilder() -> APIURLBuilder {
        APIURLBuilder()
    }

    func buildAPIHostProvider() -> APIHostProvider {
        APIHostProvider(
            sdkEnvironmentProvider: configuration.serverEnvironment,
            apiURLBuilder: buildAPIURLBuilder()
        )
    }

    func buildAPIResponseDecoder() -> APIResponseDecoder {
        AcquiringAPIResponseDecoder(decoder: JSONDecoder())
    }

    private func buildURLRequestBuilder() -> IURLRequestBuilder {
        URLRequestBuilder(
            additionalParametersProvider: AdditionalParametersProvider(terminalKey: configuration.credential.terminalKey),
            jsonParametersEncoder: JSONEncoding(options: .sortedKeys)
        )
    }
}
