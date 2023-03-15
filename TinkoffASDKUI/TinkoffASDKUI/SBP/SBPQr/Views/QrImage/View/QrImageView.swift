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

    private lazy var stackView = UIStackView()
    private lazy var imageView = UIImageView()
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
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(webView)

        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: stackView.heightAnchor),
        ])
    }
}

// MARK: - IQrImageViewInput

extension QrImageView {
    func set(qrCodeHTML: String) {
        imageView.isHidden = true
        webView.isHidden = false
        webView.loadHTMLString(qrCodeHTML, baseURL: nil)
    }

    func set(qrCodeUrl: String) {
        webView.isHidden = true
        imageView.isHidden = false
        imageView.image = UIImage(qr: qrCodeUrl)
        presenter?.qrDidLoad()
    }
}

// MARK: - WKNavigationDelegate

extension QrImageView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        presenter?.qrDidLoad()
    }
}
