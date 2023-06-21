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
        allureId(2570089, "Отмена добавления карты закрытием webview для 3DS v1")

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

    func test_3DSV2ConfirmationInWebView_cancelled() {
        allureId(2564233, "Отмена добавления карты закрытием webview для 3DS v2")

        // given
        var addCardReturnedCancelled = false
        addCardServiceMock.attachCardCompletionStub = .success(
            buildAttachCardPayload(attachCardStatus: .needConfirmation3DSACS(.fake()))
        )

        threeDSWebFlowControllerMock.confirm3DSACSCompletionInput = .cancelled

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
        allureId(2556847, "Неуспешное добавление non 3ds карты")

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

    // MARK: - CheckType 3DS

    func test_addCard_fullFlow_checkType_3DS_3ds_v1_success() {
        allureId(2556839, "Добавление карты с прохождением 3DS v1")
        test_3ds_v2_success_addcard_full_flow(checkType: .check3DS)
    }

    func test_addCard_fullFlow_checkType_3DS_3ds_v2_success() {
        allureId(2556959, "Добавление карты с прохождением 3DS v2")
        test_3ds_v2_success_addcard_full_flow(checkType: .check3DS)
    }

    func test_addCard_fullFlow_checkType_3DS_no3DSCheck_success() {
        allureId(2556846, "Успешное добавление 3ds карты без прохождения 3ds")
        test_3ds_addcard_full_flow_no_3ds_confirmation(checkType: .check3DS, attachStatus: .authorized)
    }

    // MARK: - CheckType 3DSHOLD

    func test_addCard_fullFlow_checkType_3DSHOLD_3ds_v1_success() {
        allureId(2307069, "Добавление карты с прохождением 3DS v1")
        test_3ds_v1_success_addcard_full_flow(checkType: .hold3DS)
    }

    func test_addCard_fullFlow_checkType_3DSHOLD_3ds_v2_success() {
        allureId(2559308, "Добавление карты с прохождением 3DS v2")
        test_3ds_v2_success_addcard_full_flow(checkType: .hold3DS)
    }

    func test_addCard_fullFlow_checkType_3DSHOLD_no3DSCheck_success() {
        allureId(2559310, "Добавление non 3ds карты")
        test_3ds_addcard_full_flow_no_3ds_confirmation(checkType: .hold3DS)
    }

    func test_addCard_fullFlow_checkType_3DSHOLD_no3DSCheck_2_success() {
        allureId(2559309, "Успешное добавление 3ds карты без прохождения 3ds")
        test_3ds_addcard_full_flow_no_3ds_confirmation(checkType: .hold3DS, attachStatus: .authorized)
    }

    // MARK: - CheckType HOLD

    func test_addCard_fullFlow_checkType_HOLD_success() {
        /// Карты на входе не имеют значения
        /// По какому пути пойдет флоу зависит от переданного checkType
        /// И ответа бекенда на v2/AttachCard
        allureId(2559314, "Успешное добавление 3ds v1 карты")
        allureId(2559317, "Успешное добавление 3ds v2 карты")
        allureId(2559316, "Успешное добавление non 3ds карты")
        test_no3ds_success_addcard_full_flow(checkType: .hold)
    }

    // MARK: - CheckType NO

    func test_addCard_fullFlow_checkType_NO_success() {
        /// Карты на входе не имеют значения
        /// По какому пути пойдет флоу зависит от переданного checkType
        /// И ответа бекенда на v2/AttachCard
        allureId(2559319, "Успешное добавление 3ds v1 карты")
        allureId(2559322, "Успешное добавление 3ds v2 карты")
        allureId(2559321, "Успешное добавление non 3ds карты")
        test_no3ds_success_addcard_full_flow(checkType: .no)
    }
}

// MARK: - Helpers

extension AddCardControllerTests {

    private func test_3ds_v1_success_addcard_full_flow(checkType: PaymentCardCheckType) {
        assert(checkType == .hold3DS || checkType == .check3DS)

        // given
        var addCardStateSucceded = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .needConfirmation3DS(.fake())))
        threeDSWebFlowControllerMock.confirm3DSCompletionStub = .succeded(.fake(status: .authorized))
        addCardServiceMock.getAddCardStateCompletionInput = .success(.fake(status: .completed))
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: checkType, addCardCompletion: {
            if case AddCardStateResult.succeded = $0 { addCardStateSucceded = true }
        })

        // then
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSCallsCount, 1)
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNotNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, 1)
        XCTAssertTrue(addCardStateSucceded)
    }

    private func test_3ds_v2_success_addcard_full_flow(checkType: PaymentCardCheckType) {
        assert(checkType == .hold3DS || checkType == .check3DS)

        // given
        var addCardStateSucceded = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .needConfirmation3DSACS(.fake())))
        threeDSWebFlowControllerMock.confirm3DSACSCompletionInput = .succeded(.fake(status: .confirmed))
        addCardServiceMock.getAddCardStateCompletionInput = .success(.fake(status: .completed))
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: checkType, addCardCompletion: {
            if case AddCardStateResult.succeded = $0 { addCardStateSucceded = true }
        })

        // then
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 1)
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNotNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, 1)
        XCTAssertTrue(addCardStateSucceded)
    }

    private func test_3ds_addcard_full_flow_no_3ds_confirmation(
        checkType: PaymentCardCheckType,
        attachStatus: AcquiringStatus = .unknown,
        attachCardStatus: AttachCardStatus = .done
    ) {
        assert(checkType == .hold3DS || checkType == .check3DS)

        // given
        var addCardStateSucceded = false
        addCardServiceMock.attachCardCompletionStub = .success(
            .fake(status: attachStatus, attachCardStatus: attachCardStatus)
        )
        threeDSWebFlowControllerMock.confirm3DSACSCompletionInput = .succeded(.fake(status: .confirmed))
        addCardServiceMock.getAddCardStateCompletionInput = .success(.fake(status: .completed))
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: checkType, addCardCompletion: {
            if case AddCardStateResult.succeded = $0 { addCardStateSucceded = true }
        })

        // then
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 0)
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 1)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNotNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, 1)
        XCTAssertTrue(addCardStateSucceded)
    }

    private func test_no3ds_success_addcard_full_flow(checkType: PaymentCardCheckType) {
        assert(checkType == .hold || checkType == .no)

        // given
        var addCardStateSucceded = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .done))
        threeDSWebFlowControllerMock.confirm3DSACSCompletionInput = .succeded(.fake(status: .confirmed))
        addCardServiceMock.getAddCardStateCompletionInput = .success(.fake(status: .completed))
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: checkType, addCardCompletion: {
            if case AddCardStateResult.succeded = $0 { addCardStateSucceded = true }
        })

        // then
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 0)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSCallsCount, 0)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 0)
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 0)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 0)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 0)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
        XCTAssertNil(addCardServiceMock.attachCardReceivedArguments?.data.deviceData)
        XCTAssertEqual(addCardServiceMock.getAddCardStateCallsCount, 1)
        XCTAssertTrue(addCardStateSucceded)
    }

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
