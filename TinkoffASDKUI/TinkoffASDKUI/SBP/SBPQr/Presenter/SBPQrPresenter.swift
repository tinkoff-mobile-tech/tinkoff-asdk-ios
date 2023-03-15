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

    private let acquiringSdk: AcquiringSdk
    private let paymentFlow: PaymentFlow?
    private let repeatedRequestHelper: IRepeatedRequestHelper
    private let paymentStatusService: IPaymentStatusService
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var textHeaderPresenter = TextHeaderViewPresenter(title: Loc.TinkoffAcquiring.View.Title.payQRCode)
    private lazy var qrImagePresenter = QrImageViewPresenter(output: self)

    // MARK: State

    private var paymentId: String?
    private var cellTypes: [SBPQrCellType] = []
    private var currentViewState: CommonSheetState = .processing
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        paymentFlow: PaymentFlow?,
        repeatedRequestHelper: IRepeatedRequestHelper,
        paymentStatusService: IPaymentStatusService,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.acquiringSdk = acquiringSdk
        self.paymentFlow = paymentFlow
        self.repeatedRequestHelper = repeatedRequestHelper
        self.paymentStatusService = paymentStatusService
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - ISBPQrViewOutput

extension SBPQrPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.getPaymentStatus()
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
            acquiringSdk.initPayment(data: .data(with: paymentOptions), completion: { [weak self] result in
                switch result {
                case let .success(initPayload):
                    self?.paymentId = initPayload.paymentId
                    self?.loadDynamicQr(paymentId: initPayload.paymentId)
                case let .failure(error):
                    self?.handleFailureGetQrData(error: error)
                }
            })
        case let .finish(paymentId, _):
            self.paymentId = paymentId
            loadDynamicQr(paymentId: paymentId)
        }
    }

    private func loadStaticQr() {
        acquiringSdk.getStaticQR(data: .imageSVG) { [weak self] result in
            self?.handleQr(result: result.map { .staticQr($0.qrCodeData) })
        }
    }

    private func loadDynamicQr(paymentId: String) {
        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
        acquiringSdk.getQR(data: qrData) { [weak self] result in
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
        // Отображение Qr происходит после того как Qr будет загружен в WebView или ImageView. (зависит от типа)
        // Так как у web view есть задержка отображения.
        // Уведомление о загрузке приходит в методе qrDidLoad()
        DispatchQueue.performOnMain {
            self.qrImagePresenter.set(qrType: qrType)
            self.cellTypes = [.textHeader(self.textHeaderPresenter), .qrImage(self.qrImagePresenter)]
            self.view?.reloadData()
        }
    }

    private func handleFailureGetQrData(error: Error) {
        DispatchQueue.performOnMain {
            self.moduleResult = .failed(error)
            self.viewUpdateStateIfNeeded(newState: .failed)
        }
    }

    private func getPaymentStatus() {
        guard let paymentId = paymentId else { return }

        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: paymentId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(payload):
                        self.handleSuccessGet(payloadInfo: payload)
                    case let .failure(error):
                        self.handleFailureGetPaymentStatus(error)
                    }
                }
            }
        }
    }

    private func handleSuccessGet(payloadInfo: GetPaymentStatePayload) {
        switch payloadInfo.status {
        case .formShowed:
            getPaymentStatus()
            viewUpdateStateIfNeeded(newState: .waiting)
        case .authorizing, .confirming:
            getPaymentStatus()
            viewUpdateStateIfNeeded(newState: .processing)
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

    static var waiting: CommonSheetState {
        CommonSheetState(
            status: .processing,
            title: Loc.CommonSheet.PaymentWaiting.title,
            secondaryButtonTitle: Loc.CommonSheet.PaymentWaiting.secondaryButton
        )
    }

    static var paid: CommonSheetState {
        CommonSheetState(status: .succeeded, title: "Оплачено", primaryButtonTitle: "Понятно")
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: "Не получилось оплатить",
            primaryButtonTitle: "Понятно"
        )
    }
}
