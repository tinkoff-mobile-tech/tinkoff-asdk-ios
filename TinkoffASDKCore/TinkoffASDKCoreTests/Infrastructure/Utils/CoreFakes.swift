//
//  CoreFakes.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 07.08.2023.
//

import Foundation
@testable import TinkoffASDKCore

extension AcquiringSdk {
    static func fake() -> AcquiringSdk {
        try! AcquiringSdk(configuration: .fake())
    }
}

extension AcquiringSdkConfiguration {
    static func fake() -> AcquiringSdkConfiguration {
        AcquiringSdkConfiguration(
            credential: .fake(),
            server: .test
        )
    }
}

extension AcquiringSdkCredential {
    static let fakeTerminalKey = "TestSDK"
    static let fakePublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5Yg3RyEkszggDVMDHCAGzJm0mYpYT53BpasrsKdby8iaWJVACj8ueR0Wj3Tu2BY64HdIoZFvG0v7UqSFztE/zUvnznbXVYguaUcnRdwao9gLUQO2I/097SHF9r++BYI0t6EtbbcWbfi755A1EWfu9tdZYXTrwkqgU9ok2UIZCPZ4evVDEzDCKH6ArphVc4+iKFrzdwbFBmPmwi5Xd6CB9Na2kRoPYBHePGzGgYmtKgKMNs+6rdv5v9VB3k7CS/lSIH4p74/OPRjyryo6Q7NbL+evz0+s60Qz5gbBRGfqCA57lUiB3hfXQZq5/q1YkABOHf9cR6Ov5nTRSOnjORgPjwIDAQAB"

    static func fake() -> AcquiringSdkCredential {
        AcquiringSdkCredential(terminalKey: fakeTerminalKey, publicKey: fakePublicKey)
    }
}

extension AttachCardData {
    static func fake() -> AttachCardData {
        AttachCardData(
            cardNumber: "22001234556789010",
            expDate: "2020-08-11",
            cvv: "231",
            requestKey: "key",
            data: nil
        )
    }
}

extension AttachCardPayload {
    static func fake(status: AcquiringStatus = .unknown, attachCardStatus: AttachCardStatus) -> AttachCardPayload {
        AttachCardPayload(
            status: status,
            requestKey: "requestKey",
            cardId: "cardId",
            rebillId: "rebillId",
            attachCardStatus: attachCardStatus
        )
    }
}

extension Checking3DSURLData {
    static func fake(threeDSMethodURL: String = URL.doesNotMatter.absoluteString) -> Checking3DSURLData {
        Checking3DSURLData(
            tdsServerTransID: "tdsServerTransID",
            threeDSMethodURL: threeDSMethodURL,
            notificationURL: "notificationURL"
        )
    }
}

extension Confirmation3DS2AppBasedData {
    static func fake() -> Confirmation3DS2AppBasedData {
        Confirmation3DS2AppBasedData(
            acsSignedContent: "acsSignedContent",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId",
            acsRefNumber: "acsRefNumber"
        )
    }
}

/// 3DS v1
extension Confirmation3DSData {
    static func fake() -> Self {
        Confirmation3DSData(
            acsUrl: "https://tinkoff.ru",
            pareq: "pareq",
            md: "md"
        )
    }
}

/// 3DS v2
extension Confirmation3DSDataACS {
    static func fake() -> Self {
        Confirmation3DSDataACS(
            acsUrl: "https://tinkoff.ru",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId"
        )
    }
}

extension FinishAuthorizeData {
    static func fake() -> FinishAuthorizeData {
        FinishAuthorizeData(
            paymentId: "id",
            paymentSource: .savedCard(cardId: "123", cvv: "213"),
            infoEmail: nil,
            amount: nil,
            data: nil
        )
    }
}

extension GetAddCardStatePayload {
    static func fake(status: AcquiringStatus, cardId: String? = "234234") -> Self {
        GetAddCardStatePayload(
            requestKey: "requestKey",
            status: status,
            cardId: cardId,
            rebillId: ""
        )
    }
}

extension GetTerminalPayMethodsPayload {
    static func fake(methods: [TerminalPayMethod], addCardScheme: Bool = false) -> Self {
        GetTerminalPayMethodsPayload(
            terminalInfo: TerminalInfo(
                payMethods: methods,
                addCardScheme: addCardScheme
            )
        )
    }
}

extension InitPayload {
    static func fake(status: AcquiringStatus = .authorized) -> InitPayload {
        InitPayload(
            amount: 100,
            orderId: "445",
            paymentId: "34243",
            status: status
        )
    }
}

extension PaymentInitData {
    static func fake() -> PaymentInitData {
        PaymentInitData(amount: Int64(5000), orderId: "order_id", customerKey: "key")
    }
}

extension ThreeDsDataBrowser {
    static func fake() -> ThreeDsDataBrowser {
        ThreeDsDataBrowser(
            threeDSCompInd: "Y",
            javaEnabled: "true",
            colorDepth: "32",
            language: "ru",
            timezone: "3",
            screenHeight: "100",
            screenWidth: "100",
            cresCallbackUrl: "cresCallbackUrl"
        )
    }
}

extension ThreeDsDataSDK {
    static func fake() -> Self {
        Self(
            sdkAppID: "sdkAppID",
            sdkEphemPubKey: "sdkEphemPubKey",
            sdkReferenceNumber: "sdkReferenceNumber",
            sdkTransID: "sdkTransID",
            sdkMaxTimeout: "sdkMaxTimeout",
            sdkEncData: "sdkEncData",
            sdkInterface: .both,
            sdkUiType: "sdkUiType"
        )
    }
}

extension URLProtectionSpaceMock {
    static func fake() -> URLProtectionSpaceMock {
        URLProtectionSpaceMock(
            host: "rest-api-test.tinkoff.ru",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        )
    }
}

extension YandexPayMethod {
    static func fake() -> YandexPayMethod {
        YandexPayMethod(
            merchantId: "merchantId",
            merchantName: "merchantName",
            merchantOrigin: "merchantOrigin",
            showcaseId: "showcaseId"
        )
    }
}

extension PaymentCard {
    static func fake() -> Self {
        PaymentCard(
            pan: "34234",
            cardId: "123213",
            status: .active,
            parentPaymentId: 123,
            expDate: "0929"
        )
    }

    static func fakeInactive() -> Self {
        PaymentCard(
            pan: "34234",
            cardId: "123213",
            status: .inactive,
            parentPaymentId: 123,
            expDate: "0929"
        )
    }

    static func fakeSber() -> Self {
        PaymentCard(
            pan: "427432",
            cardId: "124913",
            status: .active,
            parentPaymentId: 123,
            expDate: "0929"
        )
    }
}

extension Array where Element == PaymentCard {
    /// Change with caution [snapshot image tests use this]
    static func fake() -> Self {
        [
            PaymentCard(
                pan: "427432",
                cardId: "124913",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "525787",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "419540",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "518901",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "510070",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "543762",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "342347",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "34234",
                cardId: "123213",
                status: .inactive,
                parentPaymentId: 123,
                expDate: "0929"
            ),
        ]
    }
}
