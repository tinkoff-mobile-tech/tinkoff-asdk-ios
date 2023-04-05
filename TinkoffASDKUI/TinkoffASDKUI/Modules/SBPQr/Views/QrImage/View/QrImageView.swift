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

    private lazy var imageBackgroundView = UIView()
    private lazy var imageView = UIImageView()
    private lazy var webView = WKWebView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupViews() {
        addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(imageView)
        imageBackgroundView.addSubview(webView)

        backgroundColor = ASDKColors.Background.neutral2.color
        layer.cornerRadius = .backgroundRadius
        imageBackgroundView.backgroundColor = .white
        imageBackgroundView.layer.cornerRadius = .backgroundRadius
        imageView.contentMode = .scaleAspectFit

        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
    }

    private func setupConstraints() {
        imageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageBackgroundView.widthAnchor.constraint(equalToConstant: .imageBackgroundSide),
            imageBackgroundView.heightAnchor.constraint(equalToConstant: .imageBackgroundSide),
            imageBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: .backgroundOffset),
            imageBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.backgroundOffset),
            imageBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),

            imageView.leftAnchor.constraint(equalTo: imageBackgroundView.leftAnchor, constant: .imageOffset),
            imageView.topAnchor.constraint(equalTo: imageBackgroundView.topAnchor, constant: .imageOffset),
            imageView.rightAnchor.constraint(equalTo: imageBackgroundView.rightAnchor, constant: -.imageOffset),
            imageView.bottomAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: -.imageOffset),

            webView.leftAnchor.constraint(equalTo: imageBackgroundView.leftAnchor, constant: .imageOffset),
            webView.topAnchor.constraint(equalTo: imageBackgroundView.topAnchor, constant: .imageOffset),
            webView.rightAnchor.constraint(equalTo: imageBackgroundView.rightAnchor, constant: -.imageOffset),
            webView.bottomAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: -.imageOffset),
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

// MARK: - Constants

private extension CGFloat {
    static let backgroundRadius: CGFloat = 16
    static let imageBackgroundSide: CGFloat = 200
    static let backgroundOffset: CGFloat = 24
    static let imageOffset: CGFloat = 16
}
