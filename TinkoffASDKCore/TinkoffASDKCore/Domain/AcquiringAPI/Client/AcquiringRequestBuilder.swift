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
    func submit3DSAuthorizationV2(data: Submit3DSAuthorizationV2Data) -> AcquiringRequest
    func getPaymentState(data: GetPaymentStateData) -> AcquiringRequest
    func charge(data: ChargeData) -> AcquiringRequest
    func getCardList(data: GetCardListData) -> AcquiringRequest
    func addCard(data: AddCardData) -> AcquiringRequest
    func attachCard(data: AttachCardData) -> AcquiringRequest
    func submitRandomAmount(data: SubmitRandomAmountData) -> AcquiringRequest
    func removeCard(data: RemoveCardData) -> AcquiringRequest
    func getQR(data: GetQRData) -> AcquiringRequest
    func getStaticQR(data: GetQRDataType) -> AcquiringRequest
    func getTinkoffPayStatus() -> AcquiringRequest
    func getTinkoffPayLink(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version
    ) -> AcquiringRequest
}

final class AcquiringRequestBuilder: IAcquiringRequestBuilder {
    private let baseURLProvider: IURLProvider
    private let publicKeyProvider: IPublicKeyProvider
    private let terminalKeyProvider: IStringProvider
    private let initParamsEnricher: IPaymentInitDataParamsEnricher
    private let cardDataFormatter: CardDataFormatter
    private let rsaEncryptor: IRSAEncryptor

    init(
        baseURLProvider: IURLProvider,
        publicKeyProvider: IPublicKeyProvider,
        terminalKeyProvider: IStringProvider,
        initParamsEnricher: IPaymentInitDataParamsEnricher,
        cardDataFormatter: CardDataFormatter,
        rsaEncryptor: IRSAEncryptor
    ) {
        self.baseURLProvider = baseURLProvider
        self.publicKeyProvider = publicKeyProvider
        self.terminalKeyProvider = terminalKeyProvider
        self.initParamsEnricher = initParamsEnricher
        self.cardDataFormatter = cardDataFormatter
        self.rsaEncryptor = rsaEncryptor
    }

    func initRequest(data: PaymentInitData) -> AcquiringRequest {
        let enrichedData = initParamsEnricher.enrich(data)
        return InitRequest(paymentInitData: enrichedData, baseURL: baseURLProvider.url)
    }

    func finishAuthorize(data: FinishAuthorizeData) -> AcquiringRequest {
        FinishAuthorizeRequest(
            requestData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
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

    func submit3DSAuthorizationV2(data: Submit3DSAuthorizationV2Data) -> AcquiringRequest {
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

    func getTinkoffPayLink(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version
    ) -> AcquiringRequest {
        GetTinkoffLinkRequest(paymentId: paymentId, version: version, baseURL: baseURLProvider.url)
    }
}
