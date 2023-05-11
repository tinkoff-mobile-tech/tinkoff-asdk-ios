//
//  SBPPaymentSheetPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPPaymentSheetPresenterTests: BaseTestCase {

    var sut: SBPPaymentSheetPresenter!

    // MARK: Mocks

    var viewMock: CommonSheetViewMock!
    var paymentSheetOutputMock: SBPPaymentSheetPresenterOutputMock!
    var paymentStatusServiceMock: PaymentStatusServiceMock!
    var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    var mainDispatchQueueMock: DispatchQueueMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(configuration: SBPConfiguration(), paymentId: "1234")
    }

    override func tearDown() {
        viewMock = nil
        paymentSheetOutputMock = nil
        paymentStatusServiceMock = nil
        repeatedRequestHelperMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad_when_status_authorized() {
        // given
        let paymentId = "11111"
        let configuration = SBPConfiguration(paymentStatusRetriesCount: 5)
        setupSut(configuration: configuration, paymentId: paymentId)

        let payload = GetPaymentStatePayload.some(status: .authorized)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInput = .success(payload)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 2)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1].state.status, .succeeded)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1].animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0].state.status, .succeeded)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0].animatePullableContainerUpdates, true)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
    }
}

// MARK: - Private methods

extension SBPPaymentSheetPresenterTests {
    func setupSut(configuration: SBPConfiguration, paymentId: String) {
        viewMock = CommonSheetViewMock()
        paymentSheetOutputMock = SBPPaymentSheetPresenterOutputMock()
        paymentStatusServiceMock = PaymentStatusServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        mainDispatchQueueMock = DispatchQueueMock()

        sut = SBPPaymentSheetPresenter(
            output: paymentSheetOutputMock,
            paymentStatusService: paymentStatusServiceMock,
            repeatedRequestHelper: repeatedRequestHelperMock,
            mainDispatchQueue: mainDispatchQueueMock,
            sbpConfiguration: configuration,
            paymentId: paymentId
        )

        sut.view = viewMock
    }
}

// MARK: - Helpers

private extension GetPaymentStatePayload {
    static func some(status: AcquiringStatus) -> GetPaymentStatePayload {
        GetPaymentStatePayload(paymentId: "121111", amount: 234, orderId: "324234", status: status)
    }
}

// final class SBPPaymentSheetPresenter: ICommonSheetPresenter {
//
//    // MARK: Dependencies
//
//    weak var view: ICommonSheetView?
//
//    private weak var output: ISBPPaymentSheetPresenterOutput?
//
//    private let paymentStatusService: IPaymentStatusService
//    private let repeatedRequestHelper: IRepeatedRequestHelper
//    private let sbpConfiguration: SBPConfiguration
//
//    // MARK: Properties
//
//    private let paymentId: String
//
//    private lazy var requestRepeatCount: Int = sbpConfiguration.paymentStatusRetriesCount
//    private var canDismissView = true
//
//    private var currentViewState: CommonSheetState = .waiting
//    private var lastPaymentInfo: PaymentResult.PaymentInfo?
//    private var lastGetPaymentStatusError: Error?
//
//    // MARK: Initialization
//
//    init(
//        output: ISBPPaymentSheetPresenterOutput?,
//        paymentStatusService: IPaymentStatusService,
//        repeatedRequestHelper: IRepeatedRequestHelper,
//        sbpConfiguration: SBPConfiguration,
//        paymentId: String
//    ) {
//        self.output = output
//        self.paymentStatusService = paymentStatusService
//        self.repeatedRequestHelper = repeatedRequestHelper
//        self.sbpConfiguration = sbpConfiguration
//        self.paymentId = paymentId
//    }
// }
//
//// MARK: - ICommonSheetPresenter
//
// extension SBPPaymentSheetPresenter {
//    func viewDidLoad() {
//        getPaymentStatus()
//        view?.update(state: currentViewState, animatePullableContainerUpdates: false)
//    }
//
//    func primaryButtonTapped() {
//        view?.close()
//    }
//
//    func secondaryButtonTapped() {
//        view?.close()
//    }
//
//    func canDismissViewByUserInteraction() -> Bool {
//        canDismissView
//    }
//
//    func viewWasClosed() {
//        switch currentViewState {
//        case .paid:
//            guard let lastPaymentInfo = lastPaymentInfo else {
//                output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .unknown)))
//                return
//            }
//
//            output?.sbpPaymentSheet(completedWith: .succeeded(lastPaymentInfo))
//        case .waiting:
//            output?.sbpPaymentSheet(completedWith: .cancelled(lastPaymentInfo))
//        case .paymentFailed:
//            output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .rejected)))
//        case .timeout:
//            output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .timeout, underlyingError: lastGetPaymentStatusError)))
//        default:
//            // во всех остальных кейсах, закрытие шторки должно быть невозможно
//            break
//        }
//    }
// }
//
//// MARK: - Private
//
// extension SBPPaymentSheetPresenter {
//    private func getPaymentStatus() {
//        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
//            guard let self = self else { return }
//
//            self.paymentStatusService.getPaymentState(paymentId: self.paymentId) { result in
//                self.mainDispatchQueueMock.async {
//                    switch result {
//                    case let .success(payload):
//                        self.handleSuccessGet(payloadInfo: payload)
//                    case let .failure(error):
//                        self.handleFailureGetPaymentStatus(error)
//                    }
//                }
//            }
//        }
//    }
//
//    private func handleSuccessGet(payloadInfo: GetPaymentStatePayload) {
//        lastPaymentInfo = payloadInfo.toPaymentInfo()
//
//        requestRepeatCount -= 1
//        let isRequestRepeatAllowed = requestRepeatCount > 0
//
//        switch payloadInfo.status {
//        case .formShowed where isRequestRepeatAllowed:
//            canDismissView = true
//            getPaymentStatus()
//            viewUpdateStateIfNeeded(newState: .waiting)
//        case .formShowed where !isRequestRepeatAllowed:
//            canDismissView = true
//            viewUpdateStateIfNeeded(newState: .timeout)
//        case .authorizing, .confirming:
//            canDismissView = false
//            getPaymentStatus()
//            viewUpdateStateIfNeeded(newState: .processing)
//        case .authorized, .confirmed:
//            canDismissView = true
//            viewUpdateStateIfNeeded(newState: .paid)
//        case .rejected:
//            canDismissView = true
//            viewUpdateStateIfNeeded(newState: .paymentFailed)
//        case .deadlineExpired:
//            canDismissView = true
//            viewUpdateStateIfNeeded(newState: .timeout)
//        default:
//            canDismissView = true
//            viewUpdateStateIfNeeded(newState: .paymentFailed)
//        }
//    }
//
//    private func handleFailureGetPaymentStatus(_ error: Error) {
//        requestRepeatCount -= 1
//        let isRequestRepeatAllowed = requestRepeatCount > 0
//        if isRequestRepeatAllowed {
//            getPaymentStatus()
//        } else {
//            canDismissView = true
//            lastGetPaymentStatusError = error
//            viewUpdateStateIfNeeded(newState: .timeout)
//        }
//    }
//
//    private func viewUpdateStateIfNeeded(newState: CommonSheetState) {
//        if currentViewState != newState {
//            currentViewState = newState
//            view?.update(state: currentViewState)
//        }
//    }
// }
//
//// MARK: - CommonSheetState + SBP States
//
// private extension CommonSheetState {
//    static var waiting: CommonSheetState {
//        CommonSheetState(
//            status: .processing,
//            title: Loc.CommonSheet.PaymentWaiting.title,
//            secondaryButtonTitle: Loc.CommonSheet.PaymentWaiting.secondaryButton
//        )
//    }
//
//    static var processing: CommonSheetState {
//        CommonSheetState(
//            status: .processing,
//            title: Loc.CommonSheet.Processing.title,
//            description: Loc.CommonSheet.Processing.description
//        )
//    }
//
//    static var paid: CommonSheetState {
//        CommonSheetState(
//            status: .succeeded,
//            title: Loc.CommonSheet.Paid.title,
//            primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
//        )
//    }
//
//    static var timeout: CommonSheetState {
//        CommonSheetState(
//            status: .failed,
//            title: Loc.CommonSheet.TimeoutFailed.title,
//            description: Loc.CommonSheet.TimeoutFailed.description,
//            secondaryButtonTitle: Loc.CommonSheet.TimeoutFailed.secondaryButton
//        )
//    }
//
//    static var paymentFailed: CommonSheetState {
//        CommonSheetState(
//            status: .failed,
//            title: Loc.CommonSheet.PaymentFailed.title,
//            description: Loc.CommonSheet.PaymentFailed.description,
//            primaryButtonTitle: Loc.CommonSheet.PaymentFailed.primaryButton
//        )
//    }
// }
//
