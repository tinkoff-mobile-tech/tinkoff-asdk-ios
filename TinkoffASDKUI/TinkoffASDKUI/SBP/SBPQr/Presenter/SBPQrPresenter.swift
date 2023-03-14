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
    private lazy var qrImagePresenter = QrImageViewPresenter()

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
            self?.handleQr(result: result.map { $0.qrCodeData })
        }
    }

    private func loadDynamicQr(paymentId: String) {
        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
        acquiringSdk.getQR(data: qrData) { [weak self] result in
            self?.handleQr(result: result.map { $0.qrCodeData })
        }
    }

    private func handleQr(result: Result<String, Error>) {
        switch result {
        case let .success(qrData):
            handleSuccessGet(qrData: qrData)
        case let .failure(error):
            handleFailureGetQrData(error: error)
        }
    }

    private func handleSuccessGet(qrData: String) {
        DispatchQueue.performOnMain {
            self.qrImagePresenter.set(qrData: qrData)
            self.cellTypes = [.textHeader(self.textHeaderPresenter), .qrImage(self.qrImagePresenter)]
            self.view?.reloadData()
            self.view?.hideCommonSheet()
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
