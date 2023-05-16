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

    
//    func viewDidLoad() {
//        view?.showCommonSheet(state: .processing, animatePullableContainerUpdates: false)
//        loadQrData()
//    }
//
//    private func loadQrData() {
//        guard let paymentFlow = paymentFlow else {
//            loadStaticQr()
//            return
//        }
//
//        switch paymentFlow {
//        case let .full(paymentOptions):
//            sbpService.initPayment(data: .data(with: paymentOptions), completion: { [weak self] result in
//                switch result {
//                case let .success(initPayload):
//                    self?.paymentId = initPayload.paymentId
//                    self?.loadDynamicQr(paymentId: initPayload.paymentId)
//                case let .failure(error):
//                    self?.handleFailureGetQrData(error: error)
//                }
//            })
//        case let .finish(paymentOptions):
//            paymentId = paymentOptions.paymentId
//            loadDynamicQr(paymentId: paymentOptions.paymentId)
//        }
//    }
//
//    private func loadDynamicQr(paymentId: String) {
//        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
//        sbpService.getQR(data: qrData) { [weak self] result in
//            self?.handleQr(result: result.map { .dynamicQr($0.qrCodeData) })
//        }
//    }
//
//    private func loadStaticQr() {
//        sbpService.getStaticQR(data: .imageSVG) { [weak self] result in
//            self?.handleQr(result: result.map { .staticQr($0.qrCodeData) })
//        }
//    }
//
//    private func handleQr(result: Result<QrImageType, Error>) {
//        switch result {
//        case let .success(qrType):
//            handleSuccessGet(qrType: qrType)
//        case let .failure(error):
//            handleFailureGetQrData(error: error)
//        }
//    }
//
//    private func handleSuccessGet(qrType: QrImageType) {
//        textHeaderPresenter = createTextHeaderPresener(for: qrType)
//
//        // Отображение Qr происходит после того как Qr будет загружен в WebView или ImageView. (зависит от типа)
//        // Так как у web view есть задержка отображения.
//        // Уведомление о загрузке приходит в методе qrDidLoad()
//        DispatchQueue.performOnMain {
//            self.qrImagePresenter.set(qrType: qrType)
//            self.cellTypes = [.textHeader(self.textHeaderPresenter), .qrImage(self.qrImagePresenter)]
//            self.view?.reloadData()
//        }
//    }
//
//    private func handleFailureGetQrData(error: Error) {
//        DispatchQueue.performOnMain {
//            self.moduleResult = .failed(error)
//            self.viewUpdateStateIfNeeded(newState: .failed)
//        }
//    }
//
//    private func viewUpdateStateIfNeeded(newState: CommonSheetState) {
//        if currentViewState != newState {
//            currentViewState = newState
//            view?.showCommonSheet(state: currentViewState)
//        }
//    }

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
