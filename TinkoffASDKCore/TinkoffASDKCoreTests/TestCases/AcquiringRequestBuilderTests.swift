//
//  AcquiringRequestBuilderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class AcquiringRequestBuilderTests: XCTestCase {
    // MARK: Properties

    private var baseURLProvider: URLProviderMock!
    private var publicKeyProviderMock: PublicKeyProviderMock!
    private var terminalKeyProvider: StringProviderMock!
    private var cardDataFormatterMock: CardDataFormatterMock!
    private var rsaEncryptorMock: RSAEncryptorMock!
    private var ipAddressProviderMock: IPAddressProviderMock!
    private var environmentParametersProviderMock: EnvironmentParametersProviderMock!
    private var sut: AcquiringRequestBuilder!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        baseURLProvider = URLProviderMock()
        publicKeyProviderMock = PublicKeyProviderMock()
        terminalKeyProvider = StringProviderMock()
        cardDataFormatterMock = CardDataFormatterMock()
        rsaEncryptorMock = RSAEncryptorMock()
        ipAddressProviderMock = IPAddressProviderMock()
        environmentParametersProviderMock = EnvironmentParametersProviderMock()
        sut = AcquiringRequestBuilder(
            baseURLProvider: baseURLProvider,
            publicKeyProvider: publicKeyProviderMock,
            terminalKeyProvider: terminalKeyProvider,
            cardDataFormatter: cardDataFormatterMock,
            rsaEncryptor: rsaEncryptorMock,
            ipAddressProvider: ipAddressProviderMock,
            environmentParametersProvider: environmentParametersProviderMock
        )
    }

    override func tearDown() {
        baseURLProvider = nil
        publicKeyProviderMock = nil
        terminalKeyProvider = nil
        cardDataFormatterMock = nil
        rsaEncryptorMock = nil
        ipAddressProviderMock = nil
        environmentParametersProviderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_initRequest() throws {
        // given
        let params = ["key": "value"]
        let data = PaymentInitData.fake()

        baseURLProvider.underlyingUrl = .doesNotMatter
        environmentParametersProviderMock.environmentParameters = params

        // when
        let request = sut.initRequest(data: data)

        // then
        let initRequest = try XCTUnwrap(request as? InitRequest)
        let dataField = try XCTUnwrap(extractDataField(from: initRequest))
        XCTAssertEqual(initRequest.baseURL, .doesNotMatter)
        XCTAssertEqual(initRequest.parameters["Amount"] as? Int64, data.amount)
        XCTAssertEqual(initRequest.parameters["OrderId"] as? String, data.orderId)
        XCTAssertEqual(initRequest.parameters["CustomerKey"] as? String, data.customerKey)
        XCTAssertEqual(dataField, params)
    }

    func test_submit3DSAuthorizationV2() throws {
        // given
        let data = CresData(cres: "cres")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.submit3DSAuthorizationV2(data: data)

        // then
        let authRequest = try XCTUnwrap(request as? Submit3DSAuthorizationV2Request)
        XCTAssertEqual(authRequest.parameters["cres"] as? String, data.cres)
    }

    func test_getPaymentState() throws {
        // given
        let data = GetPaymentStateData(paymentId: "id")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getPaymentState(data: data)

        // then
        let stateRequest = try XCTUnwrap(request as? GetPaymentStateRequest)
        XCTAssertEqual(stateRequest.parameters["PaymentId"] as? String, data.paymentId)
    }

    func test_charge() throws {
        // given
        let chargeData = ChargeData(paymentId: "id", rebillId: "rebill_id")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.charge(data: chargeData)

        // when
        let chargeRequest = try XCTUnwrap(request as? ChargePaymentRequest)
        XCTAssertEqual(chargeRequest.baseURL, .doesNotMatter)
        XCTAssertEqual(chargeRequest.parameters["PaymentId"] as? String, chargeData.paymentId)
        XCTAssertEqual(chargeRequest.parameters["RebillId"] as? String, chargeData.rebillId)
    }

    func test_getCardList() throws {
        // given
        let data = GetCardListData(customerKey: "key")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getCardList(data: data)

        // then
        let cardListRequest = try XCTUnwrap(request as? GetCardListRequest)
        XCTAssertEqual(cardListRequest.parameters["CustomerKey"] as? String, data.customerKey)
    }

    func test_addCard() throws {
        // given
        let data = AddCardData(with: .check3DS, customerKey: "key")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.addCard(data: data)

        // then
        let cardListRequest = try XCTUnwrap(request as? AddCardRequest)
        XCTAssertEqual(cardListRequest.parameters["CustomerKey"] as? String, data.customerKey)
    }

    func test_getAddCardState() throws {
        // given
        let data = GetAddCardStateData(requestKey: "key")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getAddCardState(data: data)

        // then
        let addCardRequest = try XCTUnwrap(request as? GetAddCardStateRequest)
        XCTAssertEqual(addCardRequest.parameters["RequestKey"] as? String, data.requestKey)
    }

    func test_submitRandomAmount() throws {
        // given
        let data = SubmitRandomAmountData(amount: 60, requestKey: "key")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.submitRandomAmount(data: data)

        // then
        let amountRequest = try XCTUnwrap(request as? SubmitRandomAmountRequest)
        XCTAssertEqual(amountRequest.parameters["RequestKey"] as? String, data.requestKey)
        XCTAssertEqual(amountRequest.parameters["Amount"] as? Int, Int(data.amount))
    }

    func test_removeCard() throws {
        // given
        let data = RemoveCardData(cardId: "id", customerKey: "key")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.removeCard(data: data)

        // then
        let removeCardRequest = try XCTUnwrap(request as? RemoveCardRequest)
        XCTAssertEqual(removeCardRequest.parameters["CustomerKey"] as? String, data.customerKey)
        XCTAssertEqual(removeCardRequest.parameters["CardId"] as? String, data.cardId)
    }

    func test_getQR() throws {
        // given
        let data = GetQRData(paymentId: "id")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getQR(data: data)

        // then
        let qrRequest = try XCTUnwrap(request as? GetQRRequest)
        XCTAssertEqual(qrRequest.parameters["PaymentId"] as? String, data.paymentId)
    }

    func test_getStaticQR() throws {
        // given
        let data = GetQRDataType.imageSVG

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getStaticQR(data: data)

        // then
        let staticRequest = try XCTUnwrap(request as? GetStaticQRRequest)
        XCTAssertEqual(staticRequest.parameters[Constants.Keys.dataType] as? String, data.rawValue)
    }

    func test_getTinkoffPayStatus() throws {
        // given
        let terminalKey = "2.0"
        baseURLProvider.underlyingUrl = .doesNotMatter
        terminalKeyProvider.stubbedValue = terminalKey

        // when
        let request = sut.getTinkoffPayStatus()

        // then
        let statusRequest = try XCTUnwrap(request as? GetTinkoffPayStatusRequest)
        XCTAssertEqual(statusRequest.path, "v2/TinkoffPay/terminals/\(terminalKey)/status")
    }

    func test_getTinkoffPayLink() throws {
        // given
        let data = GetTinkoffLinkData(paymentId: "id", version: "2.0")

        baseURLProvider.underlyingUrl = .doesNotMatter

        // when
        let request = sut.getTinkoffPayLink(data: data)

        // then
        let linkRequest = try XCTUnwrap(request as? GetTinkoffLinkRequest)
        XCTAssertEqual(
            linkRequest.path,
            "v2/TinkoffPay/transactions/\(data.paymentId)/versions/\(data.version)/link"
        )
    }

    func test_getTerminalPayMethods() throws {
        // given
        let terminalKey = "2.0"

        baseURLProvider.underlyingUrl = .doesNotMatter
        terminalKeyProvider.stubbedValue = terminalKey

        // when
        let request = sut.getTerminalPayMethods()

        // then
        let linkRequest = try XCTUnwrap(request as? GetTerminalPayMethodsRequest)
        XCTAssertEqual(linkRequest.queryItems.count, 2)
        XCTAssertEqual(linkRequest.queryItems[0].value, terminalKey)
        XCTAssertEqual(linkRequest.queryItems[1].value, "SDK")
    }

    // MARK: Private

    private func extractDataField(from request: AcquiringRequest) -> [String: String]? {
        request.parameters["DATA"] as? [String: String]
    }
}
