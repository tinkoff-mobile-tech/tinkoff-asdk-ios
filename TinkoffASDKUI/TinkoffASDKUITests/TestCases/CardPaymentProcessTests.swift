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
        let payload = Check3DSVersionPayload(
            version: "",
            tdsServerTransID: "",
            threeDSMethodURL: "",
            paymentSystem: ""
        )

        // when
        let dependencies = try start_paymentFlow_finish(
            check3DSVersionResult: .success(payload)
        )

        // then
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentNeedCollect3DsCallCounter,
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
        let dependencies = try start_paymentFlow_finish(
            check3DSVersionResult: .success(payload)
        )

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.finishAuthorizeCallCounter,
            1
        )
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
        check3DSVersionResult: Result<Check3DSVersionPayload, Error>
    ) throws -> Dependencies {
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

        threeDsServiceMock.check3DSVersionStubReturnValue = { passedArgs -> Cancellable in
            // handle failure flow
            passedArgs.completion(check3DSVersionResult)
            return EmptyCancellable()
        }

        // when

        sutPaymentProcess.start()

        return dependencies
    }
}

// MARK: - Dependencies

extension CardPaymentProcessTests {

    struct Dependencies {
        let sut: CardPaymentProcess
        let sutAsPaymentProcess: PaymentProcess
        let paymentDelegateMock: MockPaymentProcessDelegate
        let ipProviderMock: MockIPAddressProvider
        let paymentsServiceMock: MockAcquiringPaymentsService
        let threeDsServiceMock: MockAcquiringThreeDsService
        let paymentFlow: PaymentFlow
        let paymentSource: PaymentSourceData
    }

    static func makeDependecies(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow
    ) -> Dependencies {
        let paymentDelegateMock = MockPaymentProcessDelegate()
        let ipProviderMock = MockIPAddressProvider()

        let paymentsServiceMock = MockAcquiringPaymentsService()
        let threeDsServiceMock = MockAcquiringThreeDsService()

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
