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
    private let baseURLProvider: IBaseURLProvider

    init(configuration: AcquiringSdkConfiguration) throws {
        self.configuration = configuration
        baseURLProvider = try BaseURLProvider(host: configuration.serverEnvironment.rawValue)
    }

    func buildAPI() -> API {
        AcquiringAPI(
            networkClient: buildNetworkClient(),
            apiDecoder: APIDecoder()
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

    func externalAPIClient() -> IExternalAPIClient {
        ExternalAPIClient(networkClient: buildNetworkClient())
    }
}

private extension CoreAssembly {
    func buildNetworkClient() -> INetworkClient {
        let networkClient = NetworkClient(
            session: buildNetworkSession(),
            requestBuilder: buildURLRequestBuilder(),
            responseValidator: HTTPURLResponseValidator()
        )

        return networkClient
    }

    func buildNetworkSession() -> INetworkSession {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = configuration.requestsTimeoutInterval
        urlSessionConfiguration.timeoutIntervalForResource = configuration.requestsTimeoutInterval
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        return NetworkSession(urlSession: urlSession)
    }

    private func buildURLRequestBuilder() -> IURLRequestBuilder {
        URLRequestBuilder(
            additionalParametersProvider: AdditionalParametersProvider(terminalKey: configuration.credential.terminalKey),
            jsonParametersEncoder: JSONEncoding(options: .sortedKeys)
        )
    }
}
