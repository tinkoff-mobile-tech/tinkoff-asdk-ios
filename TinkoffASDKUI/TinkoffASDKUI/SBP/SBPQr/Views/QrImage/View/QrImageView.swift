//
//  QrImageView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import UIKit
import WebKit

typealias QrImageTableCell = TableCell<QrImageView>

final class QrImageView: UIView, IQrImageViewInput {
    // MARK: Dependencies

    var presenter: IQrImageViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Subviews

    private lazy var webView = WKWebView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: leftAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.rightAnchor.constraint(equalTo: rightAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.widthAnchor.constraint(equalTo: webView.heightAnchor),
        ])
    }
}

// MARK: - IQrImageViewInput

extension QrImageView {
    func set(qrData: String) {
        showQRCode(data: qrData)
    }
}

// MARK: - Private

extension QrImageView {
    private func showQRCode(data: String) {
        let qrCodeBase64String = Data(data.utf8).base64EncodedString()
        let qrCodeHTML = qrCodeHTML(with: qrCodeBase64String)
        webView.loadHTMLString(qrCodeHTML, baseURL: nil)
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
