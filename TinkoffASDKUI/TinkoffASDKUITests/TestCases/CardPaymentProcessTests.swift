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

        paymentsServiceMock.initPaymentStubReturn = { passedArgs -> Cancellable in
            passedArgs.completion(.failure(TestsError.basic))
            return EmptyCancellable()
        }

        // when

        sutPaymentProcess.start()

        // then

        let paymentDidFailedArgs = dependencies.paymentDelegateMock.paymentDidFailedPassedArguments

        let cardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId
        let rebillId = sutPaymentProcess.paymentSource.getCardAndRebillId().rebillId

        XCTAssertTrue(paymentsServiceMock.initPaymentCallCounter == 1)
        XCTAssertEqual(
            paymentsServiceMock.initPaymentPassedArguments?.data,
            .data(with: paymentOptions)
        )

        XCTAssertTrue(dependencies.paymentDelegateMock.paymentDidFailedCallCounter == 1)
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

        let didFinishArgs = dependencies.paymentDelegateMock.paymentDidFinishPassedArguments
        let paymentSourceCardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId

        // then

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
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
            dependencies.paymentDelegateMock.paymentNeed3DsConfirmationCallCounter,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DsConfirmationPassedArguments?.need3DSConfirmation,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCallCounter,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSPassedArguments?.need3DSConfirmationACS,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedPassedArguments?.need3DSConfirmationAppBased,
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

        let payemtnDidFailedArgs = dependencies.paymentDelegateMock.paymentDidFailedPassedArguments
        let paymentSourceCardId = sutPaymentProcess.paymentSource.getCardAndRebillId().cardId

        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedCallCounter, 1)

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
            dependencies.paymentDelegateMock.paymentNeedCollect3DsCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
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
            dependencies.paymentDelegateMock.paymentNeed3DsConfirmationCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
            dependencies.paymentDelegateMock.paymentNeed3DsConfirmationCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishPassedArguments?.state.status,
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
        let error = try XCTUnwrap(dependencies.paymentDelegateMock.paymentDidFailedPassedArguments?.error)

        XCTAssertEqualTypes(errorStub, error)
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
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
            dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter,
            0
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
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
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
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
            dependencies.paymentsServiceMock.finishAuthorizeCallCounter,
            1
        )
    }

    func test_thatOldRequestIsCancelled_whenNewRequestAssigned() {
        // given
        let dependencies = prepareSut()
        let requestMock = CancellableMock()

        dependencies.paymentsServiceMock.initPaymentStubReturn = { _ in requestMock }

        // when
        dependencies.sutAsPaymentProcess.start()
        dependencies.sutAsPaymentProcess.cancel()

        // then
        XCTAssertTrue(requestMock.invokedCancel)
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
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
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
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
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
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
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

        paymentsServiceMock.initPaymentStubReturn = { passedArgs -> Cancellable in
            passedArgs.completion(.success(initPayload))
            return EmptyCancellable()
        }

        threeDsServiceMock.check3DSVersionStubReturnValue = { passedArgs -> Cancellable in
            // handle failure flow
            passedArgs.completion(.success(check3DsVersionPayload))
            return EmptyCancellable()
        }

        paymentsServiceMock.finishAuthorizeStubReturn = { passedArgs in
            passedArgs.completion(finishAuthorizeResult)
            return EmptyCancellable()
        }

        // when

        sutPaymentProcess.start()

        // then
        let check3dsArgs = threeDsServiceMock.check3DSVersionPassedArguments

        XCTAssertTrue(threeDsServiceMock.check3DSVersionCallCounter == 1)

        XCTAssertEqual(
            check3dsArgs?.data.paymentId,
            initPayload.paymentId
        )

        XCTAssertEqual(
            check3dsArgs?.data.paymentSource,
            dependencies.paymentSource
        )

        XCTAssertTrue(paymentsServiceMock.finishAuthorizeCallCounter == 1)

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

        dependencies.paymentDelegateMock.paymentNeedCollect3DsCompletionInput = ThreeDSDeviceInfo.fake()
        threeDsServiceMock.check3DSVersionStubReturnValue = { passedArgs -> Cancellable in
            // handle failure flow
            passedArgs.completion(check3DSVersionResult)
            return EmptyCancellable()
        }

        dependencies.paymentsServiceMock.finishAuthorizeCompletionInput = responseStatus
        dependencies.paymentDelegateMock.paymentNeed3DsConfirmationCompletionInput = confirmationCompletion
        dependencies.paymentDelegateMock.paymentNeed3DsConfirmationCancelledInput = confirmationCancelled
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSCompletionInput = confirmationCompletion
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationACSConfirmationCancelledInput = confirmationCancelled
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedConfirmationCancelledInput = confirmationCancelled
        dependencies.paymentDelegateMock.paymentNeed3DSConfirmationAppBasedCompletionInput = confirmationCompletion
        dependencies.paymentDelegateMock.startAppBasedFlowCompletionClosureInput = startAppBasedFlowCompletion

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
        let ipProviderMock: MockIPAddressProvider
        let paymentsServiceMock: AcquiringPaymentsServiceMock
        let threeDsServiceMock: AcquiringThreeDsServiceMock
        let paymentFlow: PaymentFlow
        let paymentSource: PaymentSourceData
    }

    static func makeDependecies(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow
    ) -> Dependencies {
        let paymentDelegateMock = PaymentProcessDelegateMock()
        let ipProviderMock = MockIPAddressProvider()

        let paymentsServiceMock = AcquiringPaymentsServiceMock()
        let threeDsServiceMock = AcquiringThreeDsServiceMock()

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
