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
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var textHeaderPresenter = TextHeaderViewPresenter(title: Loc.TinkoffAcquiring.View.Title.payQRCode)
    private lazy var qrImagePresenter = QrImageViewPresenter(output: self)

    // MARK: State

    private var cellTypes: [SBPQrCellType] = []
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        paymentFlow: PaymentFlow?,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.acquiringSdk = acquiringSdk
        self.paymentFlow = paymentFlow
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
}

// MARK: - IQrImageViewPresenterOutput

extension SBPQrPresenter: IQrImageViewPresenterOutput {
    func qrDidLoad() {
        view?.hideCommonSheet()
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
                    self?.loadDynamicQr(paymentId: initPayload.paymentId)
                case let .failure(error):
                    self?.handleFailureGetQrData(error: error)
                }
            })
        case let .finish(paymentId, _):
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
            self.view?.showCommonSheet(state: .failed)
        }
    }
}

// MARK: - CommonSheetState + MainForm States

private extension CommonSheetState {
    static var processing: CommonSheetState {
        CommonSheetState(status: .processing)
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
