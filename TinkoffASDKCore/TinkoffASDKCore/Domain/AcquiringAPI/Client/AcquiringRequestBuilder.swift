//
//  AcquiringRequestBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 05.10.2022.
//

import Foundation

protocol IAcquiringRequestBuilder {
    func initRequest(data: PaymentInitData) -> AcquiringRequest
    func finishAuthorize(data: FinishAuthorizeData) -> AcquiringRequest
    func check3DSVersion(data: Check3DSVersionData) -> AcquiringRequest
    func submit3DSAuthorizationV2(data: CresData) -> AcquiringRequest
    func getPaymentState(data: GetPaymentStateData) -> AcquiringRequest
    func charge(data: ChargeData) -> AcquiringRequest
    func getCardList(data: GetCardListData) -> AcquiringRequest
    func addCard(data: AddCardData) -> AcquiringRequest
    func attachCard(data: AttachCardData) -> AcquiringRequest
    func getAddCardState(data: GetAddCardStateData) -> AcquiringRequest
    func submitRandomAmount(data: SubmitRandomAmountData) -> AcquiringRequest
    func removeCard(data: RemoveCardData) -> AcquiringRequest
    func getQR(data: GetQRData) -> AcquiringRequest
    func getStaticQR(data: GetQRDataType) -> AcquiringRequest
    func getTinkoffPayStatus() -> AcquiringRequest
    func getTinkoffPayLink(data: GetTinkoffLinkData) -> AcquiringRequest
    func getTerminalPayMethods() -> AcquiringRequest
}

final class AcquiringRequestBuilder: IAcquiringRequestBuilder {
    private let baseURLProvider: IURLProvider
    private let publicKeyProvider: IPublicKeyProvider
    private let terminalKeyProvider: IStringProvider
    private let cardDataFormatter: CardDataFormatter
    private let rsaEncryptor: IRSAEncryptor
    private let ipAddressProvider: IIPAddressProvider
    private let environmentParametersProvider: IEnvironmentParametersProvider

    init(
        baseURLProvider: IURLProvider,
        publicKeyProvider: IPublicKeyProvider,
        terminalKeyProvider: IStringProvider,
        cardDataFormatter: CardDataFormatter,
        rsaEncryptor: IRSAEncryptor,
        ipAddressProvider: IIPAddressProvider,
        environmentParametersProvider: IEnvironmentParametersProvider
    ) {
        self.baseURLProvider = baseURLProvider
        self.publicKeyProvider = publicKeyProvider
        self.terminalKeyProvider = terminalKeyProvider
        self.cardDataFormatter = cardDataFormatter
        self.rsaEncryptor = rsaEncryptor
        self.ipAddressProvider = ipAddressProvider
        self.environmentParametersProvider = environmentParametersProvider
    }

    func initRequest(data: PaymentInitData) -> AcquiringRequest {
        InitRequest(
            paymentInitData: data,
            environmentParametersProvider: environmentParametersProvider,
            baseURL: baseURLProvider.url
        )
    }

    func finishAuthorize(data: FinishAuthorizeData) -> AcquiringRequest {
        FinishAuthorizeRequest(
            requestData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            ipAddressProvider: ipAddressProvider,
            environmentParametersProvider: environmentParametersProvider,
            publicKey: publicKeyProvider.publicKey,
            baseURL: baseURLProvider.url
        )
    }

    func check3DSVersion(data: Check3DSVersionData) -> AcquiringRequest {
        Check3DSVersionRequest(
            check3DSRequestData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKeyProvider.publicKey,
            baseURL: baseURLProvider.url
        )
    }

    func submit3DSAuthorizationV2(data: CresData) -> AcquiringRequest {
        Submit3DSAuthorizationV2Request(data: data, baseURL: baseURLProvider.url)
    }

    func getPaymentState(data: GetPaymentStateData) -> AcquiringRequest {
        GetPaymentStateRequest(data: data, baseURL: baseURLProvider.url)
    }

    func charge(data: ChargeData) -> AcquiringRequest {
        ChargePaymentRequest(data: data, baseURL: baseURLProvider.url)
    }

    func getCardList(data: GetCardListData) -> AcquiringRequest {
        GetCardListRequest(getCardListData: data, baseURL: baseURLProvider.url)
    }

    func addCard(data: AddCardData) -> AcquiringRequest {
        AddCardRequest(initAddCardData: data, baseURL: baseURLProvider.url)
    }

    func attachCard(data: AttachCardData) -> AcquiringRequest {
        AttachCardRequest(
            data: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKeyProvider.publicKey,
            baseURL: baseURLProvider.url
        )
    }

    func getAddCardState(data: GetAddCardStateData) -> AcquiringRequest {
        GetAddCardStateRequest(data: data, baseURL: baseURLProvider.url)
    }

    func submitRandomAmount(data: SubmitRandomAmountData) -> AcquiringRequest {
        SubmitRandomAmountRequest(submitRandomAmountData: data, baseURL: baseURLProvider.url)
    }

    func removeCard(data: RemoveCardData) -> AcquiringRequest {
        RemoveCardRequest(data: data, baseURL: baseURLProvider.url)
    }

    func getQR(data: GetQRData) -> AcquiringRequest {
        GetQRRequest(data: data, baseURL: baseURLProvider.url)
    }

    func getStaticQR(data: GetQRDataType) -> AcquiringRequest {
        GetStaticQRRequest(sourceType: data, baseURL: baseURLProvider.url)
    }

    func getTinkoffPayStatus() -> AcquiringRequest {
        GetTinkoffPayStatusRequest(
            terminalKey: terminalKeyProvider.value,
            baseURL: baseURLProvider.url
        )
    }

    func getTinkoffPayLink(data: GetTinkoffLinkData) -> AcquiringRequest {
        GetTinkoffLinkRequest(data: data, baseURL: baseURLProvider.url)
    }

    func getTerminalPayMethods() -> AcquiringRequest {
        GetTerminalPayMethodsRequest(baseURL: baseURLProvider.url, terminalKey: terminalKeyProvider.value)
    }
}
