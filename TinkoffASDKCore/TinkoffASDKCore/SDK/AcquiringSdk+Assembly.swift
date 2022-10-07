//
//  AcquiringSdk+Assembly.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

public enum AcquiringSdkError: Error {
    case publicKey(String)
    case url
}

public extension AcquiringSdk {
    /// Создает новый экземпляр SDK
    convenience init(configuration: AcquiringSdkConfiguration) throws {
        let publicKeyProvider = try PublicKeyProvider(string: configuration.credential.publicKey)
            .orThrow(AcquiringSdkError.publicKey(configuration.credential.publicKey))

        let acquiringURLProvider = try URLProvider(host: configuration.serverEnvironment.rawValue)
            .orThrow(AcquiringSdkError.url)

        let appBasedConfigURLProvider = try URLProvider(host: configuration.configEnvironment.rawValue)
            .orThrow(AcquiringSdkError.url)

        let terminalKeyProvider = StringProvider(value: configuration.credential.terminalKey)
        let networkSession = NetworkSession.build(requestsTimeout: configuration.requestsTimeoutInterval)
        let networkClient = NetworkClient.build(session: networkSession)
        let externalClient = ExternalAPIClient(networkClient: networkClient)
        let externalRequests = ExternalRequestBuilder(appBasedConfigURLProvider: appBasedConfigURLProvider)
        let ipAddressProvider = IPAddressProvider(factory: IPAddressFactory())
        let deviceInfoProvider = DeviceInfoProvider()
        let acquiringClient = AcquiringAPIClient.build(terminalKeyProvider: terminalKeyProvider, networkClient: networkClient)
        let threeDSURLBuilder = ThreeDSURLBuilder(urlProvider: acquiringURLProvider)

        let acquiringRequests = AcquiringRequestBuilder.build(
            acquiringURLProvider: acquiringURLProvider,
            publicKeyProvider: publicKeyProvider,
            terminalKeyProvider: terminalKeyProvider,
            language: configuration.language
        )

        let threeDSURLRequestsBuilder = ThreeDSURLRequestBuilder(
            threeDSURLBuilder: threeDSURLBuilder,
            deviceInfoProvider: deviceInfoProvider
        )

        let coreAssembly = CoreAssembly(configuration: configuration, urlProvider: acquiringURLProvider)

        self.init(
            coreAssembly: coreAssembly,
            acquiringAPI: acquiringClient,
            acquiringRequests: acquiringRequests,
            externalAPI: externalClient,
            externalRequests: externalRequests,
            ipAddressProvider: ipAddressProvider,
            threeDSURLRequestBuilder: threeDSURLRequestsBuilder,
            threeDSURLBuilder: threeDSURLBuilder,
            language: configuration.language
        )
    }
}

// MARK: - AcquiringAPIClient

private extension AcquiringAPIClient {
    static func build(terminalKeyProvider: IStringProvider, networkClient: INetworkClient) -> IAcquiringAPIClient {
        AcquiringAPIClient(
            requestAdapter: AcquiringRequestAdapter(terminalKeyProvider: terminalKeyProvider),
            networkClient: networkClient,
            apiDecoder: APIDecoder()
        )
    }
}

// MARK: - AcquiringRequestBuilder

private extension AcquiringRequestBuilder {
    static func build(
        acquiringURLProvider: IURLProvider,
        publicKeyProvider: IPublicKeyProvider,
        terminalKeyProvider: IStringProvider,
        language: AcquiringSdkLanguage?
    ) -> AcquiringRequestBuilder {
        AcquiringRequestBuilder(
            baseURLProvider: acquiringURLProvider,
            publicKeyProvider: publicKeyProvider,
            terminalKeyProvider: terminalKeyProvider,
            initParamsEnricher: PaymentInitDataParamsEnricher(language: language),
            cardDataFormatter: CardDataFormatter(),
            rsaEncryptor: RSAEncryptor()
        )
    }
}

// MARK: - NetworkClient

private extension NetworkClient {
    static func build(session: INetworkSession) -> NetworkClient {
        NetworkClient(
            session: session,
            requestBuilder: URLRequestBuilder.build(),
            responseValidator: HTTPURLResponseValidator()
        )
    }
}

// MARK: - NetworkSession

private extension NetworkSession {
    static func build(requestsTimeout: TimeInterval) -> NetworkSession {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = requestsTimeout
        urlSessionConfiguration.timeoutIntervalForResource = requestsTimeout
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        return NetworkSession(urlSession: urlSession)
    }
}

// MARK: - URLRequestBuilder

private extension URLRequestBuilder {
    static func build() -> URLRequestBuilder {
        URLRequestBuilder(jsonParametersEncoder: JSONEncoding(options: .sortedKeys))
    }
}
