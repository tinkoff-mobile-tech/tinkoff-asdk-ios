//
//  CommonSheetStatusView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.04.2023.
//

import UIKit

final class CommonSheetStatusView: UIView {
    // MARK: Subviews

    private lazy var activityIndicator = ActivityIndicatorView(style: .xlYellow)

    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: CommonSheetStatusView

    func set(status: CommonSheetState.Status) {
        switch status {
        case .processing:
            activityIndicator.alpha = 1
            iconView.alpha = .zero
        case .succeeded:
            iconView.image = Asset.Illustrations.checkCirclePositive.image
            iconView.alpha = 1
            activityIndicator.alpha = .zero
        case .failed:
            iconView.image = Asset.Illustrations.crossCircle.image
            iconView.alpha = 1
            activityIndicator.alpha = .zero
        }
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(activityIndicator)
        addSubview(iconView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        set(status: .processing)
    }
}
