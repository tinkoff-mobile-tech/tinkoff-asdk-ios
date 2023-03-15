//
//  QrImageViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import Foundation

enum QrImageType {
    case staticQr(String)
    case dynamicQr(String)
}

final class QrImageViewPresenter: IQrImageViewOutput {
    // MARK: IQrImageViewOutput Properties

    weak var view: IQrImageViewInput? {
        didSet { setupView() }
    }

    private weak var output: IQrImageViewPresenterOutput?

    // MARK: Dependencies

    private var qrType: QrImageType? {
        didSet {
            setupView()
        }
    }

    init(qrType: QrImageType? = nil, output: IQrImageViewPresenterOutput?) {
        self.qrType = qrType
        self.output = output
    }

    // MARK: Public

    func set(qrType: QrImageType) {
        self.qrType = qrType
    }
}

// MARK: - IQrImageViewOutput

extension QrImageViewPresenter {
    func qrDidLoad() {
        output?.qrDidLoad()
    }
}

// MARK: - Private

extension QrImageViewPresenter {
    private func setupView() {
        guard let qrType = qrType else { return }

        switch qrType {
        case let .staticQr(qrData):
            let qrCodeBase64String = Data(qrData.utf8).base64EncodedString()
            let qrCodeHTML = qrCodeHTML(with: qrCodeBase64String)
            view?.set(qrCodeHTML: qrCodeHTML)
        case let .dynamicQr(qrUrl):
            view?.set(qrCodeUrl: qrUrl)
        }
    }

    private func qrCodeHTML(with qrData: String) -> String {
        """
        <!DOCTYPE html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>QR-code</title>
            <style>
                body {
                    margin:0;
                    padding:0;
                }
                .qr {
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    height: 100vh;
                    background-repeat: no-repeat;
                    background-size: contain;
                    width: 100%;
                    background-position: center;
                    background-image:url('data:image/svg+xml;base64,\(qrData)')
                }
            </style>
        </head>
        <body>
            <div class="qr"/>
        </body>
        </html>
        """
    }
}
