//
//  AcquiringRequestBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 05.10.2022.
//

import Foundation

final class AcquiringRequestBuilder {
    private let terminalKey: String
    private let publicKey: SecKey
    private let baseURL: URL
    private let cardDataFormatter = CardDataFormatter()
    private let rsaEncryptor = RSAEncryptor()

    init(terminalKey: String, publicKey: SecKey, baseURL: URL) {
        self.terminalKey = terminalKey
        self.baseURL = baseURL
        self.publicKey = publicKey
    }

    func initRequest(data: PaymentInitData) -> InitRequest {
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        return InitRequest(paymentInitData: enrichedData, baseURL: baseURL)
    }

    func finishAuthorize(data: FinishPaymentRequestData) -> FinishAuthorizeRequest {
        FinishAuthorizeRequest(
            requestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func check3DSVersion(data: Check3DSRequestData) -> Check3DSVersionRequest {
        Check3DSVersionRequest(
            check3DSRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func getPaymentState(data: GetPaymentStateData) -> GetPaymentStateRequest {
        GetPaymentStateRequest(data: data, baseURL: baseURL)
    }

    func charge(data: ChargeRequestData) -> ChargePaymentRequest {
        ChargePaymentRequest(data: data, baseURL: baseURL)
    }

    func getCardList(data: GetCardListData) -> GetCardListRequest {
        GetCardListRequest(getCardListData: data, baseURL: baseURL)
    }

    func addCard(data: InitAddCardData) -> AddCardRequest {
        AddCardRequest(initAddCardData: data, baseURL: baseURL)
    }

    func attachCard(data: FinishAddCardData) -> AttachCardRequest {
        AttachCardRequest(
            finishAddCardData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func submitRandomAmount(data: SubmitRandomAmountData) -> SubmitRandomAmountRequest {
        SubmitRandomAmountRequest(submitRandomAmountData: data, baseURL: baseURL)
    }

    func deactivateCard(data: InitDeactivateCardData) -> RemoveCardRequest {
        RemoveCardRequest(deactivateCardData: data, baseURL: baseURL)
    }

    func getQR(data: PaymentInvoiceQRCodeData) -> GetQrRequest {
        GetQrRequest(data: data, baseURL: baseURL)
    }

    func getStaticQR(data: PaymentInvoiceSBPSourceType) -> GetStaticQrRequest {
        GetStaticQrRequest(sourceType: data, baseURL: baseURL)
    }

    func getTinkoffPayStatus() -> GetTinkoffPayStatusRequest {
        GetTinkoffPayStatusRequest(terminalKey: terminalKey, baseURL: baseURL)
    }

    func getTinkoffPayLink(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version
    ) -> GetTinkoffLinkRequest {
        GetTinkoffLinkRequest(paymentId: paymentId, version: version, baseURL: baseURL)
    }
}
