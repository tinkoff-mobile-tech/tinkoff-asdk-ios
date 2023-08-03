//
//  CardPaymentProcessTests.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class CardPaymentProcessTests: XCTestCase {

    // MARK: - when start() + paymentsFlow == .full()

    func test_start_payment_failure() throws {
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        let dependencies = Self.makeDependecies(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow
        )

        let sutPaymentProcess = dependencies.sutAsPaymentProcess
        let paymentsServiceMock = dependencies.paymentsServiceMock

        paymentsServiceMock.initPaymentCompletionClosureInput = .failure(TestsError.basic)

        // when

        sutPaymentProcess.start()

        // then

        let paymentDidFailedArgs = dependencies.paymentDelegateMock.paymentDidFailedWithReceivedArguments

        let cardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId
        let rebillId = sutPaymentProcess.paymentSource.getCardAndRebillId().rebillId

        XCTAssertTrue(paymentsServiceMock.initPaymentCallsCount == 1)
        XCTAssertEqual(
            paymentsServiceMock.initPaymentReceivedArguments?.data,
            .data(with: paymentOptions)
        )

        XCTAssertTrue(dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount == 1)
        XCTAssertEqual(paymentDidFailedArgs?.paymentProcess.paymentSource, sutPaymentProcess.paymentSource)
        XCTAssertEqual(paymentDidFailedArgs?.cardId, cardId)
        XCTAssertEqual(paymentDidFailedArgs?.rebillId, rebillId)
        XCTAssertNotNil(paymentDidFailedArgs?.error)
    }

    func test_start_payment_success_paymentSource_Card_finishAuthorize_success_responseStatus_done() throws {
        let paymentStatePayload = GetPaymentStatePayload(
            paymentId: "1111",
            amount: 234,
            orderId: "324234",
            status: .authorized
        )

        // when

        let dependencies = try start_payment_success_paymentSource_Card_finishAuthorize_success(finishAuthorizeResponse: .done(paymentStatePayload))

        let sutPaymentProcess = dependencies.sutAsPaymentProcess

        let didFinishArgs = dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments
        let paymentSourceCardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId

        // then

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )

        XCTAssertEqual(
            didFinishArgs?.paymentProcess.paymentId,
            sutPaymentProcess.paymentId
        )

        XCTAssertEqual(didFinishArgs?.cardId, paymentSourceCardId)
    }

    func test_start_payment_success_paymentSource_Card_finishAuthorize_success_responseStatus_needConfirmation3DS() throws {

        let confirmationData = Confirmation3DSData(
            acsUrl: "acsUrl",
            pareq: "pareq",
            md: "md"
        )

        // when
        let dependencies = try start_payment_success_paymentSource_Card_finishAuthorize_success(finishAuthorizeResponse: .needConfirmation3DS(confirmationData))

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationCallsCount,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationReceivedArguments?.data,
            confirmationData
        )
    }

    func test_start_payment_success_paymentSource_Card_finishAuthorize_success_responseStatus_needConfirmation3DSAcs() throws {

        let confirmationData = Confirmation3DSDataACS(
            acsUrl: "acsUrl",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId"
        )

        // when
        let dependencies = try start_payment_success_paymentSource_Card_finishAuthorize_success(finishAuthorizeResponse: .needConfirmation3DSACS(confirmationData))

        // then

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCallsCount,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSReceivedArguments?.data,
            confirmationData
        )
    }

    func test_start_payment_success_paymentSource_Card_finishAuthorize_success_responseStatus_needConfirmation3DS2AppBased() throws {

        let confirmationData = Confirmation3DS2AppBasedData(
            acsSignedContent: "acsSignedContent",
            acsTransId: "acsTransId",
            tdsServerTransId: "tdsServerTransId",
            acsRefNumber: "acsRefNumber"
        )

        // when
        let dependencies = try start_payment_success_paymentSource_Card_finishAuthorize_success(finishAuthorizeResponse: .needConfirmation3DS2AppBased(confirmationData))

        // then

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedReceivedArguments?.data,
            confirmationData
        )
    }

    func test_start_payment_success_paymentSource_Card_finishAuthorize_failure() throws {

        // when

        let dependencies = try start_payment_success_paymentSource_Card_finishAuthorize(
            finishAuthorizeResult: .failure(TestsError.basic),
            finishAuthorizeResponse: .unknown
        )

        let sutPaymentProcess = dependencies.sutAsPaymentProcess

        let payemtnDidFailedArgs = dependencies.paymentDelegateMock.paymentDidFailedWithReceivedArguments
        let paymentSourceCardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId

        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount, 1)

        XCTAssertEqual(payemtnDidFailedArgs?.cardId, paymentSourceCardId)
    }

    // MARK: - when start() + paymentsFlow == .finish()

    func test_Start_paymentFlow_finish_Check3DSVersion_success_hpayloadIsNotNill() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v2))
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeedToCollect3DSDataCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DS_authorized() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v1)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS(.fake()))),
            confirmationCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            2
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .authorized
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DS_cancelled() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v1)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS(.fake()))),
            confirmationCancelled: ()
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .cancelled
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DSACS_authorized() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v2)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DSACS(.fake()))),
            confirmationCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationCallsCount,
            0
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            2
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .authorized
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DSACS_cancelled() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v2)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DSACS(.fake()))),
            confirmationCancelled: ()
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .cancelled
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DS2AppBased_authorized() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))),
            confirmationCompletion: .success(.fake()),
            startAppBasedFlowCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            2
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .authorized
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DS2AppBased_cancelled() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))),
            confirmationCancelled: (),
            startAppBasedFlowCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithReceivedArguments?.state.status,
            .cancelled
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmation3DS2AppBased_failed() throws {
        // given
        let errorStub = ErrorStub()

        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))),
            startAppBasedFlowCompletion: .failure(errorStub)
        )

        // then
        let error = try XCTUnwrap(dependencies.paymentDelegateMock.paymentDidFailedWithReceivedArguments?.error)

        XCTAssertEqualTypes(errorStub, error)
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_NeedConfirmationUnknown_doNothing() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .v1)),
            responseStatus: .success(.fake(responseStatus: .unknown)),
            confirmationCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount,
            0
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            0
        )
    }

    func test_Start_paymentFlow_finish_Check3DSVersion_failure() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .failure(ErrorStub())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_Check3DSVersion_success_hpayloadIsNill() throws {
        let payload = Check3DSVersionPayload(
            version: "",
            tdsServerTransID: nil,
            threeDSMethodURL: nil,
            paymentSystem: nil
        )

        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(payload)
        )

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.finishAuthorizeCallsCount,
            1
        )
    }

    func test_thatOldRequestIsCancelled_whenNewRequestAssigned() {
        // given
        let dependencies = prepareSut()
        let requestMock = CancellableMock()

        dependencies.paymentsServiceMock.initPaymentReturnValue = requestMock

        // when
        dependencies.sutAsPaymentProcess.start()
        dependencies.sutAsPaymentProcess.cancel()

        // then
        XCTAssertEqual(requestMock.cancelCallsCount, 1)
    }

    func test_Start_paymentFlow_finish_needConfirmation3DSACS_failed() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DSACS(.fake()))),
            confirmationCompletion: .failure(ErrorStub()),
            startAppBasedFlowCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_needConfirmation3DS_failed() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS(.fake()))),
            confirmationCompletion: .failure(ErrorStub()),
            startAppBasedFlowCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_needConfirmation3DS2AppBased_failed() throws {
        // when
        let dependencies = start_paymentFlow_finish(
            check3DSVersionResult: .success(.fake(version: .appBased)),
            responseStatus: .success(.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))),
            confirmationCompletion: .failure(ErrorStub()),
            startAppBasedFlowCompletion: .success(.fake())
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    // MARK: Private

    private func prepareSut() -> CardPaymentProcessTests.Dependencies {
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        let dependencies = Self.makeDependecies(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow
        )

        return dependencies
    }
}

// MARK: - BaseTest Start

extension CardPaymentProcessTests {

    func start_payment_success_paymentSource_Card_finishAuthorize_success(finishAuthorizeResponse: PaymentFinishResponseStatus) throws -> Dependencies {
        let finishAuthorizePayload = makeFinishPaymentPayload(responseStatus: finishAuthorizeResponse)

        return try start_payment_success_paymentSource_Card_finishAuthorize(finishAuthorizeResult: .success(finishAuthorizePayload), finishAuthorizeResponse: finishAuthorizeResponse)
    }

    func start_payment_success_paymentSource_Card_finishAuthorize(
        finishAuthorizeResult: Result<FinishAuthorizePayload, Error>,
        finishAuthorizeResponse: PaymentFinishResponseStatus
    ) throws -> Dependencies {
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let paymentFlow = PaymentFlow.full(paymentOptions: paymentOptions)

        let dependencies = Self.makeDependecies(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow
        )

        let sutPaymentProcess = dependencies.sutAsPaymentProcess
        let paymentsServiceMock = dependencies.paymentsServiceMock
        let threeDsServiceMock = dependencies.threeDsServiceMock

        let initPayload = InitPayload(
            amount: 234,
            orderId: "43243",
            paymentId: "4324342",
            status: .authorized
        )

        let check3DsVersionPayload = Check3DSVersionPayload(
            version: "2.0",
            tdsServerTransID: nil,
            threeDSMethodURL: nil,
            paymentSystem: nil
        )

        // finishAuthorizeStubReturn

        paymentsServiceMock.initPaymentCompletionClosureInput = .success(initPayload)

        threeDsServiceMock.check3DSVersionCompletionClosureInput = .success(check3DsVersionPayload)

        paymentsServiceMock.finishAuthorizeCompletionClosureInput = finishAuthorizeResult

        // when

        sutPaymentProcess.start()

        // then
        let check3dsArgs = threeDsServiceMock.check3DSVersionReceivedArguments

        XCTAssertTrue(threeDsServiceMock.check3DSVersionCallsCount == 1)

        XCTAssertEqual(
            check3dsArgs?.data.paymentId,
            initPayload.paymentId
        )

        XCTAssertEqual(
            check3dsArgs?.data.paymentSource,
            dependencies.paymentSource
        )

        XCTAssertTrue(paymentsServiceMock.finishAuthorizeCallsCount == 1)

        return dependencies
    }

    func start_paymentFlow_finish(
        check3DSVersionResult: Result<Check3DSVersionPayload, Error>,
        responseStatus: Result<FinishAuthorizePayload, Error> = .success(.fake(responseStatus: .done(.fake()))),
        confirmationCompletion: Result<GetPaymentStatePayload, Error>? = nil,
        confirmationCancelled: Void? = nil,
        startAppBasedFlowCompletion: Result<ThreeDSDeviceInfo, Error>? = nil
    ) -> Dependencies {
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let customerOptions = CustomerOptions(customerKey: "somekey", email: "someemail")
        let options = FinishPaymentOptions(paymentId: "32423", amount: 100, orderId: "id", customerOptions: customerOptions)
        let paymentFlow = PaymentFlow.finish(paymentOptions: options)

        let dependencies = Self.makeDependecies(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow
        )

        let sutPaymentProcess = dependencies.sutAsPaymentProcess
        let threeDsServiceMock = dependencies.threeDsServiceMock

        dependencies.paymentDelegateMock.paymentNeedToCollect3DSDataCompletionClosureInput = ThreeDSDeviceInfo.fake()
        threeDsServiceMock.check3DSVersionCompletionClosureInput = check3DSVersionResult
        dependencies.paymentsServiceMock.finishAuthorizeCompletionClosureInput = responseStatus
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationCompletionClosureInput = confirmationCompletion
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationConfirmationCancelledShouldExecute = true
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCompletionClosureInput = confirmationCompletion
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSConfirmationCancelledShouldExecute = true
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedConfirmationCancelledShouldExecute = true
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCompletionClosureInput = confirmationCompletion
        dependencies.paymentDelegateMock.startAppBasedFlowCheck3dsPayloadCompletionClosureInput = startAppBasedFlowCompletion

        // when

        sutPaymentProcess.start()

        return dependencies
    }
}

// MARK: - Dependencies

extension CardPaymentProcessTests {

    struct Dependencies {
        let sut: CardPaymentProcess
        let sutAsPaymentProcess: IPaymentProcess
        let paymentDelegateMock: PaymentProcessDelegateMock
        let ipProviderMock: IPAddressProviderMock
        let paymentsServiceMock: AcquiringPaymentsServiceMock
        let threeDsServiceMock: AcquiringThreeDSServiceMock
        let paymentFlow: PaymentFlow
        let paymentSource: PaymentSourceData
    }

    static func makeDependecies(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow
    ) -> Dependencies {
        let paymentDelegateMock = PaymentProcessDelegateMock()
        let ipProviderMock = IPAddressProviderMock()

        let paymentsServiceMock = AcquiringPaymentsServiceMock()
        let threeDsServiceMock = AcquiringThreeDSServiceMock()

        let sut = CardPaymentProcess(
            paymentsService: paymentsServiceMock,
            threeDsService: threeDsServiceMock,
            threeDSDeviceInfoProvider: ThreeDSDeviceInfoProviderMock(),
            ipProvider: ipProviderMock,
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            delegate: paymentDelegateMock
        )

        return Dependencies(
            sut: sut,
            sutAsPaymentProcess: sut,
            paymentDelegateMock: paymentDelegateMock,
            ipProviderMock: ipProviderMock,
            paymentsServiceMock: paymentsServiceMock,
            threeDsServiceMock: threeDsServiceMock,
            paymentFlow: paymentFlow,
            paymentSource: paymentSource
        )
    }

    func makeFinishPaymentPayload(responseStatus: PaymentFinishResponseStatus) -> FinishAuthorizePayload {
        let orderAmount: Int64 = 324
        let paymentId: Int64 = 111
        let orderId = "234244"
        let paymentStatus = AcquiringStatus.authorized

        let finishAuthorizePayload = FinishAuthorizePayload(
            status: .authorized,
            paymentState: GetPaymentStatePayload(
                paymentId: String(paymentId),
                amount: orderAmount,
                orderId: orderId,
                status: paymentStatus
            ),
            responseStatus: responseStatus
        )

        return finishAuthorizePayload
    }
}
