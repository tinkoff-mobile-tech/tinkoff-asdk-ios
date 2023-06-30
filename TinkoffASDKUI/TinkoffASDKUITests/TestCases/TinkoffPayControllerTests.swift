//
//  TinkoffPayControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 31.05.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class TinkoffPayControllerTests: BaseTestCase {
    /// Dependencies
    private var paymentService: AcquiringPaymentsServiceMock!
    private var tinkoffPayServiceMock: AcquiringTinkoffPayServiceMock!
    private var applicationOpenerMock: UIApplicationMock!
    private var paymentStatusServiceMock: PaymentStatusServiceMock!
    private var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    private var queueMock: DispatchQueueMock!
    private var delegateMock: TinkoffPayControllerDelegateMock!

    // MARK: - Setup

    override func tearDown() {
        paymentService = nil
        paymentService = nil
        tinkoffPayServiceMock = nil
        applicationOpenerMock = nil
        paymentStatusServiceMock = nil
        repeatedRequestHelperMock = nil
        queueMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_thatControllerSendsRequest() {
        allureId(2500814, "Каждые 3 сек отправляется запрос /v2/GetState")
        allureId(2500852, "Отображение \"Время оплаты истекло\" по истечению таймера")

        // given
        let sut = prepareSut(paymentStatusRetriesCount: 10)
        tinkoffPayServiceMock.stubbedGetTinkoffPayLinkCompletion = .success(.fake())
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = (0 ... .paymentStatusRetriesCount).map { _ in
            .success(.fake(status: .checking3ds))
        }
        applicationOpenerMock.canOpenURLReturnValue = true
        applicationOpenerMock.openCompletionClosureInput = true
        queueMock.asyncWorkShouldExecute = true

        // when
        sut.performPayment(paymentFlow: .finish(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, .paymentStatusRetriesCount)
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithTimeoutCallsCount, 1)
    }

    func test_thatControllerShowsTimeoutMessage_whenStatusIsDeadlineExpired() {
        allureId(2500854, "Отображение \"Время оплаты истекло\" получили статус DEADLINE_EXPIRED")

        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)
        tinkoffPayServiceMock.stubbedGetTinkoffPayLinkCompletion = .success(.fake())
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .deadlineExpired))]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        applicationOpenerMock.canOpenURLReturnValue = true
        applicationOpenerMock.openCompletionClosureInput = true
        queueMock.asyncWorkShouldExecute = true

        // when
        sut.performPayment(paymentFlow: .finish(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithTimeoutCallsCount, 1)
    }

    // MARK: - Private

    private func prepareSut(paymentStatusRetriesCount: Int) -> TinkoffPayController {
        paymentService = AcquiringPaymentsServiceMock()
        paymentService = AcquiringPaymentsServiceMock()
        tinkoffPayServiceMock = AcquiringTinkoffPayServiceMock()
        applicationOpenerMock = UIApplicationMock()
        paymentStatusServiceMock = PaymentStatusServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        queueMock = DispatchQueueMock()
        delegateMock = TinkoffPayControllerDelegateMock()
        let sut = TinkoffPayController(
            paymentService: paymentService,
            tinkoffPayService: tinkoffPayServiceMock,
            applicationOpener: applicationOpenerMock,
            paymentStatusService: paymentStatusServiceMock,
            repeatedRequestHelper: repeatedRequestHelperMock,
            paymentStatusRetriesCount: paymentStatusRetriesCount,
            mainDispatchQueue: queueMock
        )
        sut.delegate = delegateMock
        return sut
    }
}

private extension Int {
    static let paymentStatusRetriesCount = 10
}
