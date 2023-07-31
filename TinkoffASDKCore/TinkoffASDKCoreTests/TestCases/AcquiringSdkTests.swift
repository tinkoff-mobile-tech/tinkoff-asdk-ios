//
//  AcquiringSdkTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class AcquiringSdkTests: XCTestCase {
    // MARK: Properties

    private var sut: AcquiringSdk!

    private var acquiringRequestsMock: AcquiringRequestBuilderMock!
    private var externalRequestsMock: ExternalRequestBuilderMock!
    private var ipAddressProviderMock: IPAddressProviderMock!
    private var threeDSFacadeMock: ThreeDSFacadeMock!
    private var languageProviderMock: LanguageProviderMock!
    private var urlDataLoaderMock: URLDataLoaderMock!

    // MARK: Initialization

    override func tearDown() {
        acquiringRequestsMock = nil
        ipAddressProviderMock = nil
        threeDSFacadeMock = nil
        languageProviderMock = nil
        urlDataLoaderMock = nil
        externalRequestsMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_createChecking3DSURL() throws {
        // given
        prepareSut()

        let requestMock = URLRequest(url: URL.doesNotMatter)
        threeDSFacadeMock.build3DSCheckURLRequestReturnValue = requestMock

        // when
        let request = try sut.createChecking3DSURL(data: .fake())

        // then
        XCTAssertEqual(request, requestMock)
        XCTAssertEqual(threeDSFacadeMock.build3DSCheckURLRequestCallsCount, 1)
    }

    func test_ipAddress() {
        // given
        prepareSut()

        let ipv4 = IPv4Address(.ipv4)
        ipAddressProviderMock.ipAddress = ipv4

        // when
        let ip = sut.ipAddress

        // then
        XCTAssertEqual(ip?.fullStringValue, ipv4?.fullStringValue)
        XCTAssertEqual(ip?.stringValue, ipv4?.fullStringValue)
    }

    func test_languageKey() {
        // given
        prepareSut()

        languageProviderMock.language = .en

        // when
        let lang = sut.languageKey

        // then
        XCTAssertEqual(lang, .en)
    }

    func test_createConfirmation3DSRequestACS() throws {
        // given
        prepareSut()

        let requestMock = URLRequest(url: URL.doesNotMatter)
        threeDSFacadeMock.buildConfirmation3DSRequestACSReturnValue = requestMock

        // when
        let request = try sut.createConfirmation3DSRequestACS(data: .fake(), messageVersion: "2.0")

        // then
        XCTAssertEqual(request, requestMock)
        XCTAssertEqual(threeDSFacadeMock.buildConfirmation3DSRequestACSCallsCount, 1)
    }

    func test_createConfirmation3DSRequest() throws {
        // given
        prepareSut()

        let requestMock = URLRequest(url: URL.doesNotMatter)
        threeDSFacadeMock.buildConfirmation3DSRequestReturnValue = requestMock

        // when
        let request = try sut.createConfirmation3DSRequest(data: .fake())

        // then
        XCTAssertEqual(request, requestMock)
        XCTAssertEqual(threeDSFacadeMock.buildConfirmation3DSRequestCallsCount, 1)
    }

    func test_confirmation3DSTerminationURL() {
        // given
        prepareSut()

        threeDSFacadeMock.urlReturnValue = .doesNotMatter

        // when
        let request = sut.confirmation3DSTerminationURL()

        // then
        XCTAssertEqual(request, .doesNotMatter)
        XCTAssertEqual(
            threeDSFacadeMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.confirmation3DSTerminationURL.rawValue
        )
    }

    func test_confirmation3DSTerminationV2URL() {
        // given
        prepareSut()

        threeDSFacadeMock.urlReturnValue = .doesNotMatter

        // when
        let request = sut.confirmation3DSTerminationV2URL()

        // then
        XCTAssertEqual(request, .doesNotMatter)
        XCTAssertEqual(
            threeDSFacadeMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.confirmation3DSTerminationV2URL.rawValue
        )
    }

    func test_confirmation3DSCompleteV2URL() {
        // given
        prepareSut()
        threeDSFacadeMock.urlReturnValue = .doesNotMatter

        // when
        let request = sut.confirmation3DSCompleteV2URL()

        // then
        XCTAssertEqual(request, .doesNotMatter)
        XCTAssertEqual(
            threeDSFacadeMock.urlReceivedArguments?.rawValue,
            ThreeDSURLType.threeDSCheckNotificationURL.rawValue
        )
    }

    func test_threeDSWebViewSHandler() {
        // given
        prepareSut()

        let handlerStub = ThreeDSWebViewHandlerStub()
        threeDSFacadeMock.threeDSWebViewHandlerReturnValue = handlerStub

        // when
        let request = sut.threeDSWebViewSHandler()

        // then
        XCTAssertTrue(request === handlerStub)
        XCTAssertEqual(threeDSFacadeMock.threeDSWebViewHandlerCallsCount, 1)
    }

    func test_threeDSDeviceInfoProvider() {
        // given
        prepareSut()

        let providerMock = ThreeDSDeviceInfoProviderMock()
        threeDSFacadeMock.threeDSDeviceInfoProviderReturnValue = providerMock

        // when
        let request = sut.threeDSDeviceInfoProvider()

        // then
        XCTAssertTrue(providerMock === (request as? ThreeDSDeviceInfoProviderMock))
        XCTAssertEqual(threeDSFacadeMock.threeDSDeviceInfoProviderCallsCount, 1)
    }

    func test_initPayment() {
        // given
        let (api, _) = prepareSut(acquiringModel: InitPayload.self, externalModel: InitPayload.self)
        acquiringRequestsMock.initRequestReturnValue = AcquiringRequestStub()

        // when
        _ = sut.initPayment(data: .fake(), completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.initRequestCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_finishAuthorize() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: FinishAuthorizePayload.self,
            externalModel: FinishAuthorizePayload.self
        )
        acquiringRequestsMock.finishAuthorizeReturnValue = AcquiringRequestStub()

        // when
        _ = sut.finishAuthorize(data: .fake(), completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.finishAuthorizeCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_check3DSVersion() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: Check3DSVersionPayload.self,
            externalModel: Check3DSVersionPayload.self
        )
        let data = Check3DSVersionData(paymentId: "id", paymentSource: .parentPayment(rebuidId: "id"))
        acquiringRequestsMock.check3DSVersionReturnValue = AcquiringRequestStub()

        // when
        _ = sut.check3DSVersion(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.check3DSVersionCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_submit3DSAuthorizationV2() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetPaymentStatePayload.self,
            externalModel: GetPaymentStatePayload.self
        )
        let data = CresData(cres: "cres")
        acquiringRequestsMock.submit3DSAuthorizationV2ReturnValue = AcquiringRequestStub()

        // when
        _ = sut.submit3DSAuthorizationV2(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.submit3DSAuthorizationV2CallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getPaymentState() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetPaymentStatePayload.self,
            externalModel: GetPaymentStatePayload.self
        )
        let data = GetPaymentStateData(paymentId: "id")
        acquiringRequestsMock.getPaymentStateReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getPaymentState(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_charge() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: ChargePayload.self,
            externalModel: ChargePayload.self
        )
        let data = ChargeData(paymentId: "paymentId", rebillId: "rebillId")
        acquiringRequestsMock.chargeReturnValue = AcquiringRequestStub()

        // when
        _ = sut.charge(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.chargeCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getCardList() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: [PaymentCard].self,
            externalModel: [PaymentCard].self
        )
        let data = GetCardListData(customerKey: "key")
        acquiringRequestsMock.getCardListReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getCardList(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getCardListCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_addCard() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: AddCardPayload.self,
            externalModel: AddCardPayload.self
        )
        let data = AddCardData(with: .check3DS, customerKey: "key")
        acquiringRequestsMock.addCardReturnValue = AcquiringRequestStub()

        // when
        _ = sut.addCard(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.addCardCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_attachCard() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: AttachCardPayload.self,
            externalModel: AttachCardPayload.self
        )
        let data = AttachCardData.fake()
        acquiringRequestsMock.attachCardReturnValue = AcquiringRequestStub()

        // when
        _ = sut.attachCard(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.attachCardCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getAddCardState() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetAddCardStatePayload.self,
            externalModel: GetAddCardStatePayload.self
        )
        let data = GetAddCardStateData(requestKey: "key")
        acquiringRequestsMock.getAddCardStateReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getAddCardState(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getAddCardStateCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_submitRandomAmount() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: SubmitRandomAmountPayload.self,
            externalModel: SubmitRandomAmountPayload.self
        )
        let data = SubmitRandomAmountData(amount: 900, requestKey: "key")
        acquiringRequestsMock.submitRandomAmountReturnValue = AcquiringRequestStub()

        // when
        _ = sut.submitRandomAmount(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.submitRandomAmountCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_removeCard() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: RemoveCardPayload.self,
            externalModel: RemoveCardPayload.self
        )
        let data = RemoveCardData(cardId: "id", customerKey: "key")
        acquiringRequestsMock.removeCardReturnValue = AcquiringRequestStub()

        // when
        _ = sut.removeCard(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.removeCardCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getQR() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetQRPayload.self,
            externalModel: GetQRPayload.self
        )
        let data = GetQRData(paymentId: "id")
        acquiringRequestsMock.getQRReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getQR(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getQRCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getStaticQR() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetStaticQRPayload.self,
            externalModel: GetStaticQRPayload.self
        )
        acquiringRequestsMock.getStaticQRReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getStaticQR(data: .imageSVG, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getStaticQRCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_loadSBPBanks() {
        // given
        let (_, api) = prepareSut(
            acquiringModel: GetSBPBanksPayload.self,
            externalModel: GetSBPBanksPayload.self
        )
        externalRequestsMock.getSBPBanksReturnValue = AcquiringRequestStub()

        // when
        _ = sut.loadSBPBanks(completion: { _ in })

        // then
        XCTAssertEqual(externalRequestsMock.getSBPBanksCallsCount, 1)
        XCTAssertEqual(api.performCallsCount, 1)
    }

    func test_getTinkoffPayStatus() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetTinkoffPayStatusPayload.self,
            externalModel: GetTinkoffPayStatusPayload.self
        )
        acquiringRequestsMock.getTinkoffPayStatusReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getTinkoffPayStatus(completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getTinkoffPayStatusCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getTinkoffPayLink() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetTinkoffLinkPayload.self,
            externalModel: GetTinkoffLinkPayload.self
        )
        let data = GetTinkoffLinkData(paymentId: "id", version: "2.0")
        acquiringRequestsMock.getTinkoffPayLinkReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getTinkoffPayLink(data: data, completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getTinkoffPayLinkCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getTerminalPayMethods() {
        // given
        let (api, _) = prepareSut(
            acquiringModel: GetTerminalPayMethodsPayload.self,
            externalModel: GetTerminalPayMethodsPayload.self
        )
        acquiringRequestsMock.getTerminalPayMethodsReturnValue = AcquiringRequestStub()

        // when
        _ = sut.getTerminalPayMethods(completion: { _ in })

        // then
        XCTAssertEqual(acquiringRequestsMock.getTerminalPayMethodsCallsCount, 1)
        XCTAssertEqual(api.performRequestCallsCount, 1)
    }

    func test_getCertsConfig() {
        // given
        let (_, api) = prepareSut(
            acquiringModel: Get3DSAppBasedCertsConfigPayload.self,
            externalModel: Get3DSAppBasedCertsConfigPayload.self
        )
        externalRequestsMock.get3DSAppBasedConfigRequestReturnValue = NetworkRequestStub()

        // when
        _ = sut.getCertsConfig(completion: { _ in })

        // then
        XCTAssertEqual(externalRequestsMock.get3DSAppBasedConfigRequestCallsCount, 1)
        XCTAssertEqual(api.performCallsCount, 1)
    }

    func test_loadData() {
        // given
        prepareSut()
        urlDataLoaderMock.loadDataReturnValue = CancellableMock()

        // when
        _ = sut.loadData(with: .doesNotMatter, completion: { _ in })

        // then
        XCTAssertEqual(urlDataLoaderMock.loadDataCallsCount, 1)
        XCTAssertEqual(urlDataLoaderMock.loadDataReceivedArguments?.url, .doesNotMatter)
    }

    // MARK: Private

    @discardableResult
    private func prepareSut<T: Decodable, R: Decodable>(
        acquiringModel: T.Type = DummyObject.self,
        externalModel: R.Type = DummyObject.self
    ) -> (AcquiringAPIClientMock<T>, ExternalAPIClientMock<R>) {
        let acquiringAPIMock = AcquiringAPIClientMock<T>()
        acquiringRequestsMock = AcquiringRequestBuilderMock()
        let externalAPIMock = ExternalAPIClientMock<R>()
        ipAddressProviderMock = IPAddressProviderMock()
        threeDSFacadeMock = ThreeDSFacadeMock()
        languageProviderMock = LanguageProviderMock()
        urlDataLoaderMock = URLDataLoaderMock()
        externalRequestsMock = ExternalRequestBuilderMock()
        sut = AcquiringSdk(
            acquiringAPI: acquiringAPIMock,
            acquiringRequests: acquiringRequestsMock,
            externalAPI: externalAPIMock,
            externalRequests: externalRequestsMock,
            ipAddressProvider: ipAddressProviderMock,
            threeDSFacade: threeDSFacadeMock,
            languageProvider: languageProviderMock,
            urlDataLoader: urlDataLoaderMock
        )
        return (acquiringAPIMock, externalAPIMock)
    }
}

// MARK: Private

private extension String {
    static let ipv4 = "192.0.2.146"
}

private extension AcquiringSdkTests {
    struct DummyObject: Decodable {}
}
