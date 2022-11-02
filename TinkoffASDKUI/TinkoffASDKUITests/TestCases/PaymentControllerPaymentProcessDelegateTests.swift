//
//  PaymentControllerPaymentProcessDelegateTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 21.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

extension TimeInterval {
    static let timeout: TimeInterval = 3
}

final class PaymentControllerPaymentProcessDelegateTests: XCTestCase {

    // MARK: - func paymentDidFinish()

    func test_paymentDidFinish_getPaymentStateStatus_cancelled() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let expectation = expectation(description: #function)

        let getPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "43243",
            amount: 123,
            orderId: "43243",
            status: .cancelled
        )

        sutDependencies.paymentControllerDelegateMock.paymentControllerPaymentWasCancelledReturnStub = { _ in
            expectation.fulfill()
        }

        // when
        sut.paymentDidFinish(
            paymentProcessMock,
            with: getPaymentStatePayload,
            cardId: "324234234",
            rebillId: "23424"
        )

        waitForExpectations(timeout: .timeout)

        // then

        XCTAssertEqual(
            sutDependencies.paymentControllerDelegateMock.paymentControllerPaymentWasCancelledCallCounter,
            1
        )
    }

    func test_paymentDidFinish_getPaymentStateStatus() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let expectation = expectation(description: #function)

        let getPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "43243",
            amount: 123,
            orderId: "43243",
            status: .authorized
        )

        sutDependencies.paymentControllerDelegateMock.paymentControllerDidFinishPaymentReturnStub = { _ in
            expectation.fulfill()
        }

        // when
        sut.paymentDidFinish(
            paymentProcessMock,
            with: getPaymentStatePayload,
            cardId: "324234234",
            rebillId: "23424"
        )

        waitForExpectations(timeout: .timeout)

        // then

        XCTAssertEqual(
            sutDependencies.paymentControllerDelegateMock.paymentControllerDidFinishPaymentCallCounter,
            1
        )
    }

    // MARK: - func needToCollect3DSData()

    func test_NeedToCollect3DSData() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let needToCollect3DSData = Checking3DSURLData(
            tdsServerTransID: "234234",
            threeDSMethodURL: "dsfsdf",
            notificationURL: "www.google.com"
        )

        let expectation = expectation(description: #function)

        // when
        sut.payment(
            paymentProcessMock,
            needToCollect3DSData: needToCollect3DSData,
            completion: { deviceParams in
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: .timeout)

        // then

        XCTAssertEqual(
            sutDependencies.paymentControllerUIProviderMock.hiddenWebViewToCollect3DSDataCallCounter,
            1
        )

        XCTAssertEqual(
            sutDependencies.threeDSServiceMock.createChecking3DSURLCallCounter,
            1
        )
    }

    // MARK: - func paymentDidFailed()

    func test_paymentDidFailed() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()
        let expectation = expectation(description: #function)

        sutDependencies.paymentControllerDelegateMock.paymentControllerDidFailedReturnStub = { _ in
            expectation.fulfill()
        }

        // when
        sut.paymentDidFailed(
            paymentProcessMock,
            with: TestsError.basic,
            cardId: "432423",
            rebillId: "2342"
        )

        waitForExpectations(timeout: .timeout)

        // then
        XCTAssertEqual(
            sutDependencies.paymentControllerDelegateMock.paymentControllerDidFailedCallCounter,
            1
        )
    }

    // MARK: - func need3DSConfirmation()

    func test_Need3DSConfirmation_threeDsService_noError() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let confirmationData = Confirmation3DSData(
            acsUrl: "",
            pareq: "",
            md: ""
        )

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmation: confirmationData,
            confirmationCancelled: {},
            completion: { _ in }
        )

        // then
        XCTAssertEqual(
            sutDependencies.threeDSServiceMock.createConfirmation3DSRequestCallCounter,
            1
        )
    }

    func test_Need3DSConfirmation_threeDsService_error() throws {
        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let confirmationData = Confirmation3DSData(
            acsUrl: "",
            pareq: "",
            md: ""
        )

        let createConfirmation3DSError = TestsError.basic

        sutDependencies.threeDSServiceMock.createConfirmation3DSRequestReturnStub = { passedArgs in
            throw createConfirmation3DSError
        }

        let failureExpectation = expectation(description: #function)

        var completionResult: Result<GetPaymentStatePayload, Error>?

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmation: confirmationData,
            confirmationCancelled: {},
            completion: { result in
                completionResult = result
                failureExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: .timeout)

        // then
        XCTAssertEqual(
            sutDependencies.threeDSServiceMock.createConfirmation3DSRequestCallCounter,
            1
        )

        let result = try XCTUnwrap(completionResult)

        if case let .failure(error) = result {
            XCTAssertTrue(error is TestsError)
        } else {
            XCTFail("Should have an error in result")
        }
    }

    // MARK: - func need3DSConfirmationACS

    func test_need3DSConfirmationACS_noError() throws {

        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()

        let confirmationData = Confirmation3DSDataACS(
            acsUrl: "",
            acsTransId: "",
            tdsServerTransId: ""
        )

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationACS: confirmationData,
            version: "234",
            confirmationCancelled: {},
            completion: { _ in }
        )

        // then
        XCTAssertEqual(
            sutDependencies.threeDSServiceMock.createConfirmation3DSRequestACSCallCounter,
            1
        )
    }

    func test_need3DSConfirmationACS_error() throws {

        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()
        let expectation = expectation(description: #function)

        let confirmationData = Confirmation3DSDataACS(
            acsUrl: "",
            acsTransId: "",
            tdsServerTransId: ""
        )

        sutDependencies.threeDSServiceMock.createConfirmation3DSRequestACSReturnStub = { _ in
            throw TestsError.basic
        }

        var completionError: Error?

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationACS: confirmationData,
            version: "234",
            confirmationCancelled: {},
            completion: { result in
                if case let .failure(error) = result {
                    completionError = error
                }
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: .timeout)

        // then
        XCTAssertEqual(
            sutDependencies.threeDSServiceMock.createConfirmation3DSRequestACSCallCounter,
            1
        )

        let error = try XCTUnwrap(completionError)
        XCTAssertTrue(error is TestsError)
    }

    // MARK: - func need3DSConfirmationAppBased

    func test_need3DSConfirmationAppBased() throws {

        let dependencies = try Self.makeDependencies()
        let sut = dependencies.sutAsProtocol
        let sutDependencies = dependencies.sutDependencies
        let paymentProcessMock = makeMockPaymentProcess()
        let tdsControllerMock = sutDependencies.tdsControllerMock
        let expectation = expectation(description: #function)

        let confirmationData = Confirmation3DS2AppBasedData(
            acsSignedContent: "",
            acsTransId: "",
            tdsServerTransId: "",
            acsRefNumber: ""
        )

        let paymentStatusResponse = PaymentStatusResponse(
            success: true,
            errorCode: 0,
            errorMessage: nil,
            orderId: "4324",
            paymentId: 324,
            amount: 324,
            status: .authorized
        )

        var resultResponse: GetPaymentStatePayload?

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationAppBased: confirmationData,
            version: "423",
            confirmationCancelled: {},
            completion: { result in
                resultResponse = try? result.get()
                expectation.fulfill()
            }
        )

        tdsControllerMock.completionHandler?(.success(paymentStatusResponse))

        // wait
        waitForExpectations(timeout: .timeout)

        // then
        let getPaymentPayload = try XCTUnwrap(resultResponse)

        XCTAssertEqual(
            getPaymentPayload.paymentId,
            String(paymentStatusResponse.paymentId)
        )
    }
}

extension PaymentControllerPaymentProcessDelegateTests {

    struct Dependencies {
        let sut: PaymentController
        let sutAsProtocol: PaymentProcessDelegate
        let sutDependencies: PaymentControllerTests.Dependencies
    }

    static func makeDependencies() throws -> Dependencies {
        let dependencies = try PaymentControllerTests.makeDependencies()

        return Dependencies(
            sut: dependencies.paymentController,
            sutAsProtocol: dependencies.paymentController,
            sutDependencies: dependencies
        )
    }

    func makeMockPaymentProcess() -> MockPaymentProcess {
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()

        let paymentProcessMock = MockPaymentProcess(
            paymentFlow: .full(paymentOptions: paymentOptions),
            paymentSource: paymentSource
        )

        return paymentProcessMock
    }
}
