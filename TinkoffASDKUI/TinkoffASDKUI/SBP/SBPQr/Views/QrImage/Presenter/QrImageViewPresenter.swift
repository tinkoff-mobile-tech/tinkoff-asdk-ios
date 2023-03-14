//
//  QrImageViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import Foundation

final class QrImageViewPresenter: IQrImageViewOutput {
    // MARK: IQrImageViewOutput Properties

    weak var view: IQrImageViewInput? {
        didSet { setupView() }
    }

    // MARK: Dependencies

    private var qrData: String? {
        didSet {
            setupView()
        }
    }

    init(qrData: String? = nil) {
        self.qrData = qrData
    }

    // MARK: Public

    func set(qrData: String) {
        self.qrData = qrData
    }

    // MARK: Private

    private func setupView() {
        guard let qrData = qrData else { return }

        view?.set(qrData: qrData)
    }
}
