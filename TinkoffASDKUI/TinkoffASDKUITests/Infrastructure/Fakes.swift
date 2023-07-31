//
//  Fakes.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 11.07.2023.
//

import Foundation
import ThreeDSWrapper
import TinkoffASDKCore
@testable import TinkoffASDKUI

extension URL {
    static let fakeVK = URL(string: "www.vk.com")!
}

extension URLRequest {
    static let fake = URLRequest(url: .fakeVK)
}

extension GetTinkoffLinkPayload {
    static func fake() -> GetTinkoffLinkPayload {
        GetTinkoffLinkPayload(redirectUrl: URL.fakeVK)
    }
}

extension Get3DSAppBasedCertsConfigPayload {
    static func fake(certificates: [CertificateData]) -> Get3DSAppBasedCertsConfigPayload {
        Get3DSAppBasedCertsConfigPayload(certificates: certificates)
    }
}

extension CertificateData {
    static func fake(type: CertificateType, algorithm: CertificateAlgorithm, forceUpdateFlag: Bool) -> CertificateData {
        CertificateData(
            paymentSystem: "Some",
            directoryServerID: "123",
            type: type,
            url: .doesNotMatter,
            notAfterDate: .distantFuture,
            sha256Fingerprint: "some",
            algorithm: algorithm,
            forceUpdateFlag: forceUpdateFlag
        )
    }
}

extension CertificateUpdatingRequest {
    static func fake() -> CertificateUpdatingRequest {
        CertificateUpdatingRequest(
            certificateType: .dsRootCA,
            directoryServerID: "asd",
            algorithm: .ec,
            notAfterDate: .distantFuture,
            sha256Fingerprint: "asd",
            url: .doesNotMatter
        )
    }
}

extension PaymentOptions {
    static func fake(from initData: PaymentInitData) -> PaymentOptions {
        let orderOptions = OrderOptions(
            orderId: initData.orderId,
            amount: initData.amount,
            description: initData.description,
            receipt: initData.receipt,
            shops: initData.shops,
            receipts: initData.receipts,
            savingAsParentPayment: initData.savingAsParentPayment ?? false
        )

        let customerOptions = initData.customerKey.map {
            CustomerOptions(customerKey: $0, email: "exampleEmail@tinkoff.ru")
        }

        return PaymentOptions(
            orderOptions: orderOptions,
            customerOptions: customerOptions,
            paymentData: initData.paymentFormData ?? [:]
        )
    }

    static func fake() -> PaymentOptions {
        PaymentOptions(orderOptions: OrderOptions.fake())
    }
}

extension PaymentFlow {
    static var fakeFullRandom: PaymentFlow {
        let amount = 2000
        let randomOrderId = String(Int64.random(in: 1000 ... 10000))
        var paymentData = PaymentInitData(amount: NSDecimalNumber(value: amount), orderId: randomOrderId, customerKey: "any key")
        paymentData.description = "Краткое описание товара"

        let receiptItems: [Item] = []

        paymentData.receipt = try? Receipt(
            shopCode: nil,
            email: "email@email.com",
            taxation: .osn,
            phone: "+79876543210",
            items: receiptItems,
            agentData: nil,
            supplierInfo: nil,
            customer: nil,
            customerInn: nil
        )

        let paymentOptions = PaymentOptions.fake(from: paymentData)
        return PaymentFlow.full(paymentOptions: paymentOptions)
    }

    static var fakeFinish: PaymentFlow {
        let customerOptions = CustomerOptions(customerKey: "somekey", email: "someemail")
        let options = FinishPaymentOptions(paymentId: "32423", amount: 100, orderId: "id", customerOptions: customerOptions)
        return PaymentFlow.finish(paymentOptions: options)
    }

    static func fake() -> PaymentFlow {
        .full(paymentOptions: .fake())
    }
}

extension InitPayload {
    static let fake = InitPayload(
        amount: 324,
        orderId: "324234",
        paymentId: "2222",
        status: .authorized
    )
}

extension GetPaymentStatePayload {
    static func fake(status: AcquiringStatus = .authorized) -> GetPaymentStatePayload {
        GetPaymentStatePayload(paymentId: "121111", amount: 234, orderId: "324234", status: status)
    }
}

extension FinishAuthorizePayload {
    static func fake(responseStatus: PaymentFinishResponseStatus) -> FinishAuthorizePayload {
        FinishAuthorizePayload(
            status: .authorized,
            paymentState: .fake(),
            responseStatus: responseStatus
        )
    }
}

extension GetQRPayload {
    static let fake = GetQRPayload(qrCodeData: "https://www.google.com", orderId: "1234", paymentId: "4567")
}

extension SBPBank {
    static var fake: SBPBank {
        SBPBank(name: "name", logoURL: nil, schema: "scheme")
    }

    static var fakeWithUrl: SBPBank {
        SBPBank(name: "name", logoURL: URL(string: "https://www.google.com"), schema: "scheme")
    }

    static func fake(_ uniqValue: Int) -> SBPBank {
        SBPBank(name: "name \(uniqValue)", logoURL: nil, schema: "scheme \(uniqValue)")
    }
}

extension MainFormDataState {
    static func fake(
        primaryPaymentMethod: MainFormPaymentMethod = .sbp,
        otherPaymentMethods: [MainFormPaymentMethod] = [.card],
        cards: [PaymentCard]? = .fake()
    ) -> MainFormDataState {
        MainFormDataState(
            primaryPaymentMethod: primaryPaymentMethod,
            otherPaymentMethods: otherPaymentMethods,
            cards: cards,
            sbpBanks: nil
        )
    }
}

extension SavedCardViewPresenter {
    static var fake: SavedCardViewPresenter {
        SavedCardViewPresenter(
            validator: CardRequisitesValidatorMock(),
            paymentSystemResolver: PaymentSystemResolverMock(),
            bankResolver: BankResolverMock(),
            output: SavedCardViewPresenterOutputMock()
        )
    }
}

extension EmailViewPresenter {
    static func fake() -> EmailViewPresenter {
        EmailViewPresenter(
            customerEmail: "",
            output: EmailViewPresenterOutputMock(),
            emailValidator: EmailValidatorMock()
        )
    }
}

extension ProtocolErrorEvent {
    static func fake() -> ProtocolErrorEvent {
        ProtocolErrorEvent(
            sdkTransactionID: .fake,
            errorMessage: ErrorMessage(
                errorCode: .fake,
                errorDescription: .fake,
                errorDetails: .fake,
                transactionID: .fake
            )
        )
    }
}

extension AcquiringUISDK {
    static func fake() -> AcquiringUISDK {
        return try! AcquiringUISDK(
            coreSDKConfiguration: .fake()
        )
    }
}

extension AuthenticationRequestParameters {
    static func fake() -> AuthenticationRequestParameters {
        AuthenticationRequestParameters(
            deviceData: "deviceData",
            sdkTransId: "sdkTransId",
            sdkAppID: "sdkAppID",
            sdkReferenceNum: "sdkReferenceNum",
            ephemeralPublic: "ephemeralPublic"
        )
    }
}

extension CardList.Card {
    static func fake(from card: PaymentCard) -> CardList.Card {
        CardList.Card(
            id: card.cardId,
            pan: card.pan,
            cardModel: DynamicIconCardView.Model(),
            bankNameText: "",
            cardNumberText: "",
            isInEditingMode: true,
            hasCheckmarkInNormalMode: true
        )
    }
}

extension CardOptions {
    static func fake() -> Self {
        CardOptions(pan: "123123123123", validThru: "0928", cvc: "123")
    }
}

extension Check3DSVersionPayload {
    static func fake(version: ThreeDSVersion) -> Check3DSVersionPayload {
        switch version {
        case .v1:
            return Check3DSVersionPayload(
                version: "1.0.0",
                tdsServerTransID: nil,
                threeDSMethodURL: nil,
                paymentSystem: nil
            )

        case .v2:
            return Check3DSVersionPayload(
                version: "2.0.0",
                tdsServerTransID: "tdsServerTransID",
                threeDSMethodURL: "threeDSMethodURL",
                paymentSystem: nil
            )
        case .appBased:
            return Check3DSVersionPayload(
                version: "2.1.0",
                tdsServerTransID: "tdsServerTransID",
                threeDSMethodURL: "threeDSMethodURL",
                paymentSystem: "mock"
            )
        }
    }
}

extension Checking3DSURLData {
    static func fake() -> Checking3DSURLData {
        Checking3DSURLData(
            tdsServerTransID: "tdsServerTransID",
            threeDSMethodURL: "method",
            notificationURL: "notification"
        )
    }
}

extension FinishPaymentOptions {
    static func fake() -> FinishPaymentOptions {
        FinishPaymentOptions(paymentId: "32432", amount: 200, orderId: "4234")
    }
}

extension GetTinkoffPayStatusPayload {
    static func fake(status: GetTinkoffPayStatusPayload.Status = .disallowed) -> GetTinkoffPayStatusPayload {
        GetTinkoffPayStatusPayload(status: status)
    }
}

extension OrderOptions {
    static func fake() -> OrderOptions {
        OrderOptions(orderId: "123", amount: 100)
    }
}

extension String {
    static let fake = "doesntMatter"
}

extension TinkoffPayMethod {
    static func fake() -> TinkoffPayMethod {
        TinkoffPayMethod(version: "1.1.1")
    }
}
