//
//  SBPQrPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 15.05.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPQrPresenterTests: BaseTestCase {
    
    var sut: SBPQrPresenter!
    
    // MARK: Mocks
    
    var viewMock: SBPQrViewMock!
    var sbpServiceMock: AcquiringSBPAndPaymentServiceMock!
    var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    var paymentStatusServiceMock: PaymentStatusServiceMock!
    var mainDispatchQueueMock: DispatchQueueMock!
    var moduleCompletionMock: PaymentResultCompletion?
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        configureSut()
    }
    
    override func tearDown() {
        viewMock = nil
        sbpServiceMock = nil
        repeatedRequestHelperMock = nil
        paymentStatusServiceMock = nil
        mainDispatchQueueMock = nil
        moduleCompletionMock = nil

        sut = nil
        
        DispatchQueueMock.performOnMainCallsCount = 0
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = false
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_viewDidLoad_when_paymentFlowNil_success() {
        // given
        let payload = GetStaticQRPayload(qrCodeData: "any data")
        sbpServiceMock.getStaticQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(sbpServiceMock.getStaticQRCallsCount, 1)
        XCTAssertEqual(sbpServiceMock.getStaticQRReceivedArguments?.data, .imageSVG)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
    }
    
    func test_viewDidLoad_when_paymentFlowNil_failure() {
        // given
        let error = NSError(domain: "error", code: 123456)
        sbpServiceMock.getStaticQRCompletionClosureInput = .failure(error)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 2)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].state.status, .failed)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].animatePullableContainerUpdates, true)
        XCTAssertEqual(sbpServiceMock.getStaticQRCallsCount, 1)
        XCTAssertEqual(sbpServiceMock.getStaticQRReceivedArguments?.data, .imageSVG)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
    }
    
    func test_viewDidLoad_when_paymentFlowFinish_success() {
        // given
        configureSut(paymentFlow: .finishAny)
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(sbpServiceMock.getQRCallsCount, 1)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
    }
   
    func test_viewDidLoad_when_paymentFlowFinish_failure() {
        // given
        configureSut(paymentFlow: .finishAny)
        
        let error = NSError(domain: "error", code: 123456)
        sbpServiceMock.getQRCompletionClosureInput = .failure(error)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 2)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].state.status, .failed)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].animatePullableContainerUpdates, true)
        XCTAssertEqual(sbpServiceMock.getQRCallsCount, 1)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
    }
    
    func test_viewDidLoad_when_paymentFlowFull_success() {
        // given
        configureSut(paymentFlow: .fullRandom)
        
        let initPayload = InitPayload.any
        let getQrPayload = GetQRPayload.any
        sbpServiceMock.initPaymentCompletionClosureInput = .success(initPayload)
        sbpServiceMock.getQRCompletionClosureInput = .success(getQrPayload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(sbpServiceMock.initPaymentCallsCount, 1)
        XCTAssertEqual(sbpServiceMock.getQRCallsCount, 1)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
    }
    
    func test_viewDidLoad_when_paymentFlowFull_failure() {
        // given
        configureSut(paymentFlow: .fullRandom)
        
        let error = NSError(domain: "error", code: 123456)
        let getQrPayload = GetQRPayload.any
        sbpServiceMock.initPaymentCompletionClosureInput = .failure(error)
        sbpServiceMock.getQRCompletionClosureInput = .success(getQrPayload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 2)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].state.status, .failed)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].animatePullableContainerUpdates, true)
        XCTAssertEqual(sbpServiceMock.initPaymentCallsCount, 1)
        XCTAssertEqual(sbpServiceMock.getQRCallsCount, 0)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
    }
    
    func test_qrDidLoad_when_authorized() {
        // given
        configureSut(paymentFlow: .finishAny)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.some(status: .authorized))]
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        viewMock.hideCommonSheetCallsCount = 0
        mainDispatchQueueMock.asyncAfterCallsCount = 0
        repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount = 0
        paymentStatusServiceMock.getPaymentStateCallsCount = 0
        mainDispatchQueueMock.asyncCallsCount = 0
        viewMock.showCommonSheetCallsCount = 0
        viewMock.showCommonSheetReceivedInvocations = []
        
        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .succeeded)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, true)
    }
    
    func test_qrDidLoad_when_confirmed() {
        // given
        configureSut(paymentFlow: .finishAny)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.some(status: .confirmed))]
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        viewMock.hideCommonSheetCallsCount = 0
        mainDispatchQueueMock.asyncAfterCallsCount = 0
        repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount = 0
        paymentStatusServiceMock.getPaymentStateCallsCount = 0
        mainDispatchQueueMock.asyncCallsCount = 0
        viewMock.showCommonSheetCallsCount = 0
        viewMock.showCommonSheetReceivedInvocations = []
        
        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .succeeded)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, true)
    }
    
    func test_qrDidLoad_when_rejected() {
        // given
        configureSut(paymentFlow: .finishAny)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.some(status: .rejected))]
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        viewMock.hideCommonSheetCallsCount = 0
        mainDispatchQueueMock.asyncAfterCallsCount = 0
        repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount = 0
        paymentStatusServiceMock.getPaymentStateCallsCount = 0
        mainDispatchQueueMock.asyncCallsCount = 0
        viewMock.showCommonSheetCallsCount = 0
        viewMock.showCommonSheetReceivedInvocations = []
        
        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .failed)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, true)
    }
    
    func test_qrDidLoad_when_undefinedStatus() {
        // given
        configureSut(paymentFlow: .finishAny)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        let statuses: [Result<GetPaymentStatePayload, Error>] =
        [.success(.some(status: .confirming)), .success(.some(status: .authorized))]
        
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = statuses
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        viewMock.hideCommonSheetCallsCount = 0
        mainDispatchQueueMock.asyncAfterCallsCount = 0
        repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount = 0
        paymentStatusServiceMock.getPaymentStateCallsCount = 0
        mainDispatchQueueMock.asyncCallsCount = 0
        viewMock.showCommonSheetCallsCount = 0
        viewMock.showCommonSheetReceivedInvocations = []
        
        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 2)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .succeeded)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, true)
    }
    
    func test_qrDidLoad_when_someFailedRequests() {
        // given
        configureSut(paymentFlow: .finishAny)
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        let error = NSError(domain: "error", code: 123456)
        let statuses: [Result<GetPaymentStatePayload, Error>] =
        [.failure(error), .failure(error), .failure(error), .success(.some(status: .authorized))]
        
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = statuses
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        
        let payload = GetQRPayload.any
        sbpServiceMock.getQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        viewMock.hideCommonSheetCallsCount = 0
        mainDispatchQueueMock.asyncAfterCallsCount = 0
        repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount = 0
        paymentStatusServiceMock.getPaymentStateCallsCount = 0
        mainDispatchQueueMock.asyncCallsCount = 0
        viewMock.showCommonSheetCallsCount = 0
        viewMock.showCommonSheetReceivedInvocations = []
        
        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 4)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 4)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 4)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state.status, .succeeded)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, true)
    }
    
    func test_qrDidLoad_when_paymentIdNil() {
        // given
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.some(status: .authorized))]
        mainDispatchQueueMock.asyncAfterShouldCalls = true
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        // when
        sut.qrDidLoad()
        
        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncAfterCallsCount, 1)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 0)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 0)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 0)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 0)
    }
    
    func test_viewWasClosed() {
        // given
        var result: PaymentResult?
        moduleCompletionMock = { res in
            result = res
        }
        configureSut()
        
        // when
        sut.viewWasClosed()
        
        // then
        XCTAssertEqual(result, .cancelled())
    }
    
    func test_numberOfRows() {
        // given
        let payload = GetStaticQRPayload(qrCodeData: "some data")
        sbpServiceMock.getStaticQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 2)
    }
    
    func test_cellTypeAtIndexPath() {
        // given
        let payload = GetStaticQRPayload(qrCodeData: "some data")
        sbpServiceMock.getStaticQRCompletionClosureInput = .success(payload)
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true
        sut.viewDidLoad()
        
        let anyTextHeaderPresenter = TextAndImageHeaderViewPresenter(title: "-")
        let anyQrImagePresenter = QrImageViewPresenter(output: nil)
        
        // when
        let cellType1 = sut.cellType(at: IndexPath(row: 0, section: 0))
        let cellType2 = sut.cellType(at: IndexPath(row: 1, section: 0))
        
        // then
        XCTAssertEqual(cellType1, .textHeader(anyTextHeaderPresenter))
        XCTAssertEqual(cellType2, .qrImage(anyQrImagePresenter))
    }
    
    func test_commonSheetViewDidTapPrimaryButton() {
        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
    }
    
    func test_commonSheetViewDidTapSecondaryButton() {
        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
    }
}

// MARK: - Private methods

extension SBPQrPresenterTests {
    private func configureSut(paymentFlow: PaymentFlow? = nil) {
        viewMock = SBPQrViewMock()
        sbpServiceMock = AcquiringSBPAndPaymentServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        paymentStatusServiceMock = PaymentStatusServiceMock()
        mainDispatchQueueMock = DispatchQueueMock()
        
        sut = SBPQrPresenter(
            sbpService: sbpServiceMock,
            paymentFlow: paymentFlow,
            repeatedRequestHelper: repeatedRequestHelperMock,
            paymentStatusService: paymentStatusServiceMock,
            mainDispatchQueue: mainDispatchQueueMock,
            moduleCompletion: moduleCompletionMock)
        
        sut.view = viewMock
    }
}
