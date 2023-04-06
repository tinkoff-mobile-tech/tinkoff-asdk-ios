//
//  AddCardControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.03.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AddCardControllerTests: BaseTestCase {

    var sut: AddCardController!

    // Mocks

    var addCardServiceMock: AddCardServiceMock!
    var threeDSDeviceInfoProviderMock: ThreeDSDeviceInfoProviderMock!
    var threeDSWebFlowControllerMock: ThreeDSWebFlowControllerMock!
    var acquiringThreeDsServiceMock: AcquiringThreeDsServiceMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        addCardServiceMock = AddCardServiceMock()
        threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()
        threeDSWebFlowControllerMock = ThreeDSWebFlowControllerMock()
        acquiringThreeDsServiceMock = AcquiringThreeDsServiceMock()
        sut = createAddCardController(checkType: .no)
    }

    override func tearDown() {
        addCardServiceMock = nil
        threeDSDeviceInfoProviderMock = nil
        threeDSWebFlowControllerMock = nil
        acquiringThreeDsServiceMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_Check3DS_AttachCard_success() {
        allureId(2397512, "Отправляем запрос v2/AttachCard в случае успешного ответа v2/Check3dsVersion")

        // when
        check3DSFlow_success(checkType: .check3DS)

        // then
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNotNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
    }

    func test_Check3dsVersion_success() {
        allureId(2397513, "Отправляем запрос v2/Check3dsVersion в случае успешного ответа v2/AddCard")
        check3DSFlow_success(checkType: .check3DS)
    }

    func test_Check3dsVersion_error() {
        allureId(2397523, "Успешно обрабатываем ошибку в случае ошибки запроса v2/Сheck3dsVersion")

        // given
        sut = createAddCardController(checkType: .check3DS)
        addCardServiceMock.check3DSVersionReturnValue = CancellableMock()
        addCardServiceMock.check3DSVersionCompletionStub = .failure(TestsError.basic)
        addCardServiceMock.attachCardReturnValue = CancellableMock()
        var didReturnError = false

        // when
        addCardFlow_success(addCardCompletion: { result in
            guard case let .failed(error) = result, error is TestsError else { return }
            didReturnError = true
        })

        // then
        XCTAssertTrue(didReturnError)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, .zero)
    }

    func test_GetAddCardState_for_attachCardStatus_done() {
        allureId(2397511, "Отправляем запрос v2/GetAddCardState в случае успешного ответа v2/AttachCard")
        allureId(2397537)

        // given
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()
        addCardServiceMock.attachCardCompletionStub = .success(buildAttachCardPayload(attachCardStatus: .done))

        // when
        check3DSFlow_success(checkType: .check3DS)

        // then
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, 1)
    }

    func test_AttachCard_checkType_HoldOrNo() {
        allureId(2397500, "Отправляем запрос v2/AttachCard в случае успешного ответа v2/AddCard для hold || no")
        // given
        sut = createAddCardController(checkType: .no)
        addCardServiceMock.attachCardReturnValue = CancellableMock()

        // when
        addCardFlow_success()

        // then
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
    }

    func test_3DSConfirmationInWebView_cancelled() {
        allureId(2397499, "Успешно обрабатываем отмену в случае статуса отмены web-view")

        // given
        var addCardReturnedCancelled = false
        addCardServiceMock.attachCardCompletionStub = .success(
            buildAttachCardPayload(attachCardStatus: .needConfirmation3DS(Confirmation3DSData.fake())
            )
        )

        threeDSWebFlowControllerMock.confirm3DSCompletionStub = .cancelled

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            guard case .cancelled = result else { return }
            addCardReturnedCancelled = true
        })

        // then
        XCTAssertTrue(addCardReturnedCancelled)
    }

    func test_3DSConfirmationInWebView_error() {
        allureId(2397498, "Успешно обрабатываем ошибку в случае ошибки web-view")

        // given
        let error = TestsError.basic
        var addCardReturnedError = false
        addCardServiceMock.attachCardCompletionStub = .success(
            buildAttachCardPayload(attachCardStatus: .needConfirmation3DS(Confirmation3DSData.fake())
            )
        )

        threeDSWebFlowControllerMock.confirm3DSCompletionStub = .failed(error)

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            if case let .failed(givenError) = result, givenError is TestsError {
                addCardReturnedError = true
            }
        })

        // then
        XCTAssertTrue(addCardReturnedError)
    }

    func test_attachCard_error() {
        allureId(2397520, "Успешно обрабатываем ошибку в случае ошибки запроса v2/AttachCard")
        // given
        addCardServiceMock.attachCardReturnValue = CancellableMock()
        addCardServiceMock.attachCardCompletionStub = .failure(TestsError.basic)
        var didReturnError = false

        // when
        addCardFlow_success(addCardCompletion: { result in
            if case let .failed(error) = result, error is TestsError {
                didReturnError = true
            }
        })

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.webFlowDelegateCallsCount, Int.zero)
        XCTAssertTrue(didReturnError)
    }

    func test_addCard_3DS_error() {
        allureId(2397519, "Успешно обрабатываем ошибку в случае ошибки запроса v2/AddCard")

        // given
        var didReturnError = false
        sut = createAddCardController(checkType: .check3DS)
        let cardOptions = CardOptions(pan: "123123213", validThru: "0928", cvc: "123")
        addCardServiceMock.addCardReturnValue = CancellableMock()
        addCardServiceMock.addCardCompletionStub = .failure(TestsError.basic)

        // when
        sut.addCard(options: cardOptions, completion: { result in
            if case let .failed(error) = result, error is TestsError {
                didReturnError = true
            }
        })

        // then
        XCTAssertTrue(didReturnError)
        XCTAssertEqual(addCardServiceMock.addCardCallsCount, 1)
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, .zero)
    }

    func test_addCard_NoCheck_error() {
        allureId(2397503, "Успешно обрабатываем ошибку в случае ошибки запроса v2/AddCard")

        // given
        addCardServiceMock.addCardReturnValue = CancellableMock()
        addCardServiceMock.addCardCompletionStub = .failure(TestsError.basic)

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in })

        // then
        XCTAssertEqual(addCardServiceMock.addCardCallsCount, 1)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, .zero)
    }

    func test_NoCheck_AttachCard_error() {
        allureId(2397504, "Успешно обрабатываем ошибку в случае ошибки запроса v2/AttachCard")

        // given
        sut = createAddCardController(checkType: .no)
        addCardServiceMock.attachCardReturnValue = CancellableMock()

        // when
        addCardFlow_success(addCardCompletion: { result in })

        // then
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, .zero)
    }
}

// MARK: - Helpers

extension AddCardControllerTests {

    private func createAddCardController(checkType: PaymentCardCheckType) -> AddCardController {
        AddCardController(
            addCardService: addCardServiceMock,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProviderMock,
            webFlowController: threeDSWebFlowControllerMock,
            threeDSService: acquiringThreeDsServiceMock,
            customerKey: "key",
            checkType: checkType
        )
    }

    private func addCardFlow_success(addCardCompletion: @escaping (AddCardStateResult) -> Void = { _ in }) {
        // given
        addCardServiceMock.addCardReturnValue = CancellableMock()
        addCardServiceMock.addCardCompletionStub = .success(
            AddCardPayload(requestKey: "requestKey", paymentId: "32423423")
        )

        // when
        sut.addCard(options: CardOptions.fake(), completion: addCardCompletion)
        // then
        XCTAssertEqual(addCardServiceMock.addCardCallsCount, 1)
    }

    private func check3DSFlow_success(
        checkType: PaymentCardCheckType,
        addCardCompletion: @escaping (AddCardStateResult) -> Void = { _ in }
    ) {
        sut = createAddCardController(checkType: checkType)
        addCardServiceMock.check3DSVersionReturnValue = CancellableMock()
        addCardServiceMock.check3DSVersionCompletionStub = .success(build3DSVersionPayload())
        addCardServiceMock.attachCardReturnValue = CancellableMock()

        // when
        addCardFlow_success(addCardCompletion: addCardCompletion)
    }

    private func build3DSVersionPayload() -> Check3DSVersionPayload {
        Check3DSVersionPayload(
            version: "1.0",
            tdsServerTransID: "",
            threeDSMethodURL: "",
            paymentSystem: ""
        )
    }

    private func buildAttachCardPayload(attachCardStatus: AttachCardStatus) -> AttachCardPayload {
        AttachCardPayload(status: .authorized, requestKey: "", cardId: "", rebillId: "", attachCardStatus: attachCardStatus)
    }
}
