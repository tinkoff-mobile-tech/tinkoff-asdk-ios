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
    // MARK: Internal Types

    enum Constants {
        static let minimalHeight: CGFloat = 248
        static let backgroundRadius: CGFloat = 16
        static let imageBackgroundSide: CGFloat = 200
        static let imageOffset: CGFloat = 16
    }

    // MARK: Dependencies

    var presenter: IQrImageViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Subviews

    private lazy var backgroundView = UIView()
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
        addSubview(backgroundView)
        backgroundView.addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(imageView)
        imageBackgroundView.addSubview(webView)

        backgroundView.backgroundColor = ASDKColors.Background.neutral2.color
        backgroundView.layer.cornerRadius = Constants.backgroundRadius
        imageBackgroundView.backgroundColor = .white
        imageBackgroundView.layer.cornerRadius = Constants.backgroundRadius
        imageView.contentMode = .scaleAspectFit

        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
    }

    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        imageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: Constants.minimalHeight),

            imageBackgroundView.widthAnchor.constraint(equalToConstant: Constants.imageBackgroundSide),
            imageBackgroundView.heightAnchor.constraint(equalToConstant: Constants.imageBackgroundSide),
            imageBackgroundView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageBackgroundView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),

            imageView.leftAnchor.constraint(equalTo: imageBackgroundView.leftAnchor, constant: Constants.imageOffset),
            imageView.topAnchor.constraint(equalTo: imageBackgroundView.topAnchor, constant: Constants.imageOffset),
            imageView.rightAnchor.constraint(equalTo: imageBackgroundView.rightAnchor, constant: -Constants.imageOffset),
            imageView.bottomAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: -Constants.imageOffset),

            webView.leftAnchor.constraint(equalTo: imageBackgroundView.leftAnchor, constant: Constants.imageOffset),
            webView.topAnchor.constraint(equalTo: imageBackgroundView.topAnchor, constant: Constants.imageOffset),
            webView.rightAnchor.constraint(equalTo: imageBackgroundView.rightAnchor, constant: -Constants.imageOffset),
            webView.bottomAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: -Constants.imageOffset),
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
