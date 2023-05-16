//
//  SBPQrPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import Foundation
import TinkoffASDKCore

final class SBPQrPresenter: ISBPQrViewOutput {

    // MARK: Dependencies

    weak var view: ISBPQrViewInput?

    private let sbpService: IAcquiringSBPService & IAcquiringPaymentsService
    private let paymentFlow: PaymentFlow?
    private let repeatedRequestHelper: IRepeatedRequestHelper
    private let paymentStatusService: IPaymentStatusService
    private let dispatchQueueType: IDispatchQueue.Type
    private let mainDispatchQueue: IDispatchQueue
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var textHeaderPresenter: ITextAndImageHeaderViewOutput = createTextHeaderPresener()
    private lazy var qrImagePresenter = QrImageViewPresenter(output: self)

    // MARK: State

    private var paymentId: String?
    private var cellTypes: [SBPQrCellType] = []
    private var currentViewState: CommonSheetState = .processing
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Initialization

    init(
        sbpService: IAcquiringSBPService & IAcquiringPaymentsService,
        paymentFlow: PaymentFlow?,
        repeatedRequestHelper: IRepeatedRequestHelper,
        paymentStatusService: IPaymentStatusService,
        mainDispatchQueue: IDispatchQueue,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.sbpService = sbpService
        self.paymentFlow = paymentFlow
        self.repeatedRequestHelper = repeatedRequestHelper
        self.paymentStatusService = paymentStatusService
        dispatchQueueType = type(of: mainDispatchQueue)
        self.mainDispatchQueue = mainDispatchQueue
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - ISBPQrViewOutput

extension SBPQrPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing, animatePullableContainerUpdates: false)
        loadQrData()
    }

    func viewWasClosed() {
        moduleCompletion?(moduleResult)
        moduleCompletion = nil
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(at indexPath: IndexPath) -> SBPQrCellType {
        cellTypes[indexPath.row]
    }

    func commonSheetViewDidTapPrimaryButton() {
        view?.closeView()
    }

    func commonSheetViewDidTapSecondaryButton() {
        view?.closeView()
    }
}

// MARK: - IQrImageViewPresenterOutput

extension SBPQrPresenter: IQrImageViewPresenterOutput {
    func qrDidLoad() {
        view?.hideCommonSheet()

        // Через 10 секунд после показа динамического QR, начинаем отслеживание статуса
        // В случае со статическим QR отслеживания статуса не начнется
        mainDispatchQueue.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.getPaymentStatus()
        }
    }
}

// MARK: - Private

extension SBPQrPresenter {
    private func loadQrData() {
        guard let paymentFlow = paymentFlow else {
            loadStaticQr()
            return
        }

        switch paymentFlow {
        case let .full(paymentOptions):
            sbpService.initPayment(data: .data(with: paymentOptions), completion: { [weak self] result in
                switch result {
                case let .success(initPayload):
                    self?.paymentId = initPayload.paymentId
                    self?.loadDynamicQr(paymentId: initPayload.paymentId)
                case let .failure(error):
                    self?.handleFailureGetQrData(error: error)
                }
            })
        case let .finish(paymentOptions):
            paymentId = paymentOptions.paymentId
            loadDynamicQr(paymentId: paymentOptions.paymentId)
        }
    }

    private func loadStaticQr() {
        sbpService.getStaticQR(data: .imageSVG) { [weak self] result in
            self?.handleQr(result: result.map { .staticQr($0.qrCodeData) })
        }
    }

    private func loadDynamicQr(paymentId: String) {
        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
        sbpService.getQR(data: qrData) { [weak self] result in
            self?.handleQr(result: result.map { .dynamicQr($0.qrCodeData) })
        }
    }

    private func handleQr(result: Result<QrImageType, Error>) {
        switch result {
        case let .success(qrType):
            handleSuccessGet(qrType: qrType)
        case let .failure(error):
            handleFailureGetQrData(error: error)
        }
    }

    private func handleSuccessGet(qrType: QrImageType) {
        textHeaderPresenter = createTextHeaderPresener(for: qrType)

        // Отображение Qr происходит после того как Qr будет загружен в WebView или ImageView. (зависит от типа)
        // Так как у web view есть задержка отображения.
        // Уведомление о загрузке приходит в методе qrDidLoad()
        dispatchQueueType.performOnMain {
            self.qrImagePresenter.set(qrType: qrType)
            self.cellTypes = [.textHeader(self.textHeaderPresenter), .qrImage(self.qrImagePresenter)]
            self.view?.reloadData()
        }
    }

    private func handleFailureGetQrData(error: Error) {
        dispatchQueueType.performOnMain {
            self.moduleResult = .failed(error)
            self.viewUpdateStateIfNeeded(newState: .failed)
        }
    }

    private func getPaymentStatus() {
        guard let paymentId = paymentId else { return }

        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: paymentId) { [weak self] result in
                self?.mainDispatchQueue.async {
                    switch result {
                    case let .success(payload):
                        self?.handleSuccessGet(payloadInfo: payload)
                    case let .failure(error):
                        self?.handleFailureGetPaymentStatus(error)
                    }
                }
            }
        }
    }

    private func handleSuccessGet(payloadInfo: GetPaymentStatePayload) {
        switch payloadInfo.status {
        case .authorized, .confirmed:
            moduleResult = .succeeded(payloadInfo.toPaymentInfo())
            viewUpdateStateIfNeeded(newState: .paid)
        case .rejected:
            moduleResult = .failed(ASDKError(code: .rejected))
            viewUpdateStateIfNeeded(newState: .failed)
        default:
            getPaymentStatus()
        }
    }

    private func handleFailureGetPaymentStatus(_ error: Error) {
        getPaymentStatus()
    }

    private func createTextHeaderPresener(for qrType: QrImageType? = nil) -> ITextAndImageHeaderViewOutput {
        let title = Loc.TinkoffAcquiring.View.Title.payQRCode

        if let qrType = qrType, case QrImageType.dynamicQr = qrType {
            return TextAndImageHeaderViewPresenter(title: title, imageAsset: Asset.Sbp.sbpNoLogo)
        } else {
            return TextAndImageHeaderViewPresenter(title: title)
        }
    }

    private func viewUpdateStateIfNeeded(newState: CommonSheetState) {
        if currentViewState != newState {
            currentViewState = newState
            view?.showCommonSheet(state: currentViewState)
        }
    }
}

// MARK: - CommonSheetState + MainForm States

private extension CommonSheetState {
    static var processing: CommonSheetState {
        CommonSheetState(status: .processing)
    }

    static var paid: CommonSheetState {
        CommonSheetState(status: .succeeded, title: Loc.CommonSheet.Paid.title, primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton)
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.FailedPayment.title,
            primaryButtonTitle: Loc.CommonSheet.FailedPayment.primaryButton
        )
    }
}
