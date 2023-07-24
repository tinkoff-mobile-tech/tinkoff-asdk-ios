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
    var tdsControllerMock: TDSControllerMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        addCardServiceMock = AddCardServiceMock()
        threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()
        threeDSWebFlowControllerMock = ThreeDSWebFlowControllerMock()
        acquiringThreeDsServiceMock = AcquiringThreeDsServiceMock()
        tdsControllerMock = TDSControllerMock()
        sut = createAddCardController(checkType: .no)
    }

    override func tearDown() {
        addCardServiceMock = nil
        threeDSDeviceInfoProviderMock = nil
        threeDSWebFlowControllerMock = nil
        acquiringThreeDsServiceMock = nil
        tdsControllerMock = nil
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

        threeDSWebFlowControllerMock.confirm3DSCompletionClosureInput = .cancelled

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

        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .cancelled

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

        threeDSWebFlowControllerMock.confirm3DSCompletionClosureInput = .failed(error)

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

    func test_addCard_recevies_error_missing_paymentId_check3ds() {
        // given
        let sut = createAddCardController(checkType: .check3DS)
        addCardServiceMock.addCardReturnValue = CancellableMock()
        addCardServiceMock.addCardCompletionStub = .success(AddCardPayload(requestKey: "requestKey", paymentId: nil))
        var receivedExpectedError = false

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in
            if case let .failed(error) = result, let castedError = error as? AddCardController.Error {
                if case .missingPaymentIdFor3DSFlow = castedError {
                    receivedExpectedError = true
                }
            }
        })
        // then
        XCTAssertEqual(addCardServiceMock.addCardCallsCount, 1)
        XCTAssertTrue(receivedExpectedError)
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 0)
    }

    func test_addCard_recevies_error_missing_paymentId_hold3ds() {
        // given
        let sut = createAddCardController(checkType: .hold3DS)
        addCardServiceMock.addCardReturnValue = CancellableMock()
        addCardServiceMock.addCardCompletionStub = .success(AddCardPayload(requestKey: "requestKey", paymentId: nil))
        var receivedExpectedError = false

        // when
        sut.addCard(options: CardOptions.fake(), completion: { result in
            if case let .failed(error) = result, let castedError = error as? AddCardController.Error {
                if case .missingPaymentIdFor3DSFlow = castedError {
                    receivedExpectedError = true
                }
            }
        })
        // then
        XCTAssertEqual(addCardServiceMock.addCardCallsCount, 1)
        XCTAssertTrue(receivedExpectedError)
        XCTAssertEqual(addCardServiceMock.check3DSVersionCallsCount, 0)
    }

    func test_webflow_getter() {
        // given
        let delegateMock = ThreeDSWebFlowDelegateMock()
        threeDSWebFlowControllerMock.webFlowDelegate = delegateMock

        // when
        let sutMock = sut.webFlowDelegate as? ThreeDSWebFlowDelegateMock

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.webFlowDelegate as? ThreeDSWebFlowDelegateMock, sutMock)
    }

    func test_webflow_setter() {
        // given
        let delegateMock = ThreeDSWebFlowDelegateMock()

        // when
        sut.webFlowDelegate = delegateMock

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.webFlowDelegate as? ThreeDSWebFlowDelegateMock, delegateMock)
    }

    func test_complete3DSMethodIfNeededAndAttachCard_no_data() {
        // given
        let check3dsVersionPayload = Check3DSVersionPayload(
            version: "2.0.0",
            tdsServerTransID: nil,
            threeDSMethodURL: nil,
            paymentSystem: "visa"
        )

        sut = createAddCardController(checkType: .check3DS)
        addCardServiceMock.check3DSVersionReturnValue = CancellableMock()
        addCardServiceMock.check3DSVersionCompletionStub = .success(check3dsVersionPayload)
        addCardServiceMock.attachCardReturnValue = CancellableMock()
        // when
        addCardFlow_success(addCardCompletion: { _ in })
        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSCallsCount, 0)
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 0)
        XCTAssertEqual(acquiringThreeDsServiceMock.confirmation3DSTerminationV2URLCallCounter, 0)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 0)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 0)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 1)
    }

    func test_complete3DSMethod_returns_error() {
        // given
        var receivedExpectedError = false
        threeDSWebFlowControllerMock.complete3DSMethodThrowableError = TestsError.basic

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            switch result {
            case let .failed(error) where (error as? TestsError) == .basic:
                receivedExpectedError = true
            default: break
            }
        })

        // then
        XCTAssertTrue(receivedExpectedError)
        XCTAssertEqual(addCardServiceMock.attachCardCallsCount, 0)
    }

    func test_missingMessageVersionFor3DS() {
        // given
        var receivedExpectedError = false
        addCardServiceMock.attachCardCompletionStub = .success(
            buildAttachCardPayload(attachCardStatus: .needConfirmation3DSACS(.fake()))
        )

        // when
        check3DSFlow_success(checkType: .no, addCardCompletion: { result in
            if case let .failed(error) = result, let castedErr = error as? AddCardController.Error {
                if case .missingMessageVersionFor3DS = castedErr {
                    receivedExpectedError = true
                }
            }
        })

        // then
        XCTAssertTrue(receivedExpectedError)
    }

    func test_3DSConfirmationInWebView_error_invalidPaymentStatus() {

        // given
        var receivedExpectedError = false
        addCardServiceMock.attachCardCompletionStub = .success(
            buildAttachCardPayload(attachCardStatus: .needConfirmation3DS(Confirmation3DSData.fake()))
        )
        threeDSWebFlowControllerMock.confirm3DSCompletionClosureInput = .succeded(.fake(status: .unknown))

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            guard case let .failed(error) = result else { return }
            guard case let castedErr = error as? AddCardController.Error else { return }
            guard case let .invalidPaymentStatus(status) = castedErr, status == .unknown else { return }
            receivedExpectedError = true
        })

        // then
        XCTAssertTrue(receivedExpectedError)
    }

    func test_getAddCardState_returns_error_on_failure() {
        // given
        var receivedExpectedError = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .needConfirmation3DSACS(.fake())))
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(.fake(status: .confirmed))
        addCardServiceMock.getAddCardStateCompletionInput = .failure(TestsError.basic)
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            if case let .failed(error) = result, let castedError = error as? TestsError {
                if castedError == .basic { receivedExpectedError = true }
            }
        })

        // then
        XCTAssertTrue(receivedExpectedError)
    }

    func test_validate_get_state_returns_error_on_wrong_status() {
        // given
        var receivedExpectedError = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .needConfirmation3DSACS(.fake())))
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(.fake(status: .confirmed))
        addCardServiceMock.getAddCardStateCompletionInput = .success(.fake(status: .unknown))
        addCardServiceMock.getAddCardStateReturnValue = CancellableMock()

        // when
        check3DSFlow_success(checkType: .check3DS, addCardCompletion: { result in
            if case let .failed(error) = result, let castedError = error as? AddCardController.Error {
                if case let .invalidCardStatus(status) = castedError, status == .unknown {
                    receivedExpectedError = true
                }
            }
        })

        // then
        XCTAssertTrue(receivedExpectedError)
    }
}

// MARK: - Helpers

extension AddCardControllerTests {

    private func test_3ds_v1_success_addcard_full_flow(checkType: PaymentCardCheckType) {
        assert(checkType == .hold3DS || checkType == .check3DS)

        // given
        var addCardStateSucceded = false
        addCardServiceMock.attachCardCompletionStub = .success(.fake(attachCardStatus: .needConfirmation3DS(.fake())))
        threeDSWebFlowControllerMock.confirm3DSCompletionClosureInput = .succeded(.fake(status: .authorized))
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
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(.fake(status: .confirmed))
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
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(.fake(status: .confirmed))
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
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(.fake(status: .confirmed))
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
            checkType: checkType,
            tdsController: tdsControllerMock
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
