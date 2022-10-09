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
        let encryptor = RSAEncryptor()

        let publicKeyProvider = try PublicKeyProvider(string: configuration.credential.publicKey, encryptor: encryptor)
            .orThrow(AcquiringSdkError.publicKey(configuration.credential.publicKey))

        let acquiringURLProvider = try URLProvider(host: configuration.serverEnvironment.rawValue)
            .orThrow(AcquiringSdkError.url)

        let appBasedConfigURLProvider = try URLProvider(host: configuration.configEnvironment.rawValue)
            .orThrow(AcquiringSdkError.url)

        let terminalKeyProvider = StringProvider(value: configuration.credential.terminalKey)
        let languageProvider = LanguageProvider(language: configuration.language)
        let networkSession = NetworkSession.build(requestsTimeout: configuration.requestsTimeoutInterval)
        let networkClient = NetworkClient.build(session: networkSession)
        let externalClient = ExternalAPIClient(networkClient: networkClient)
        let externalRequests = ExternalRequestBuilder(appBasedConfigURLProvider: appBasedConfigURLProvider)
        let ipAddressProvider = IPAddressProvider(factory: IPAddressFactory())
        let deviceInfoProvider = DeviceInfoProvider()
        let acquiringClient = AcquiringAPIClient.build(terminalKeyProvider: terminalKeyProvider, networkClient: networkClient)
        let initEnricher = PaymentInitDataParamsEnricher(deviceInfoProvider: deviceInfoProvider, language: configuration.language)
        let threeDSFacade = ThreeDSFacade.build(acquiringURLProvider: acquiringURLProvider, languageProvider: languageProvider)

        let acquiringRequests = AcquiringRequestBuilder(
            baseURLProvider: acquiringURLProvider,
            publicKeyProvider: publicKeyProvider,
            terminalKeyProvider: terminalKeyProvider,
            initParamsEnricher: initEnricher,
            cardDataFormatter: CardDataFormatter(),
            rsaEncryptor: encryptor
        )

        self.init(
            acquiringAPI: acquiringClient,
            acquiringRequests: acquiringRequests,
            externalAPI: externalClient,
            externalRequests: externalRequests,
            ipAddressProvider: ipAddressProvider,
            threeDSFacade: threeDSFacade,
            languageProvider: languageProvider
        )
    }
}

// MARK: - AcquiringAPIClient

private extension AcquiringAPIClient {
    static func build(terminalKeyProvider: IStringProvider, networkClient: INetworkClient) -> IAcquiringAPIClient {
        AcquiringAPIClient(
            requestAdapter: AcquiringRequestAdapter(terminalKeyProvider: terminalKeyProvider),
            networkClient: networkClient,
            apiDecoder: APIDecoder(),
            deprecatedDecoder: DeprecatedDecoder()
        )
    }
}

// MARK: - NetworkClient

private extension NetworkClient {
    static func build(session: INetworkSession) -> NetworkClient {
        NetworkClient(
            session: session,
            requestBuilder: URLRequestBuilder(),
            statusCodeValidator: HTTPStatusCodeValidator()
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

// MARK: - ThreeDSFacade

private extension ThreeDSFacade {
    static func build(acquiringURLProvider: IURLProvider, languageProvider: ILanguageProvider) -> ThreeDSFacade {
        let urlBuilder = ThreeDSURLBuilder(baseURLProvider: acquiringURLProvider)
        let deviceInfoProvider = DeviceInfoProvider()
        let urlRequestBuilder = ThreeDSURLRequestBuilder(urlBuilder: urlBuilder, deviceInfoProvider: deviceInfoProvider)
        let webViewHandlerBuilder = ThreeDSWebViewHandlerBuilder(threeDSURLBuilder: urlBuilder, decoder: JSONDecoder())
        let deviceParamsProviderBuilder = ThreeDSDeviceParamsProviderBuilder(languageProvider: languageProvider, urlBuilder: urlBuilder)

        return ThreeDSFacade(
            threeDSURLBuilder: urlBuilder,
            threeDSURLRequestBuilder: urlRequestBuilder,
            webViewHandlerBuilder: webViewHandlerBuilder,
            deviceParamsProviderBuilder: deviceParamsProviderBuilder
        )
    }
}
