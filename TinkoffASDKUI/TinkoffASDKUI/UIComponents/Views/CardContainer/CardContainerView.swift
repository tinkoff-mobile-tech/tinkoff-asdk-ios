//
//  CardContainerView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import UIKit

final class CardContainerView: UIView {
    // MARK: Style

    struct Style {
        let backgroundColor: UIColor
        let shadowConfiguration: ShadowConfiguration
    }

    // MARK: Subviews

    private(set) lazy var contentView = UIView()
    private lazy var backgroundView = UIView()

    // MARK: Dependencies

    private let style: Style
    private let insets: UIEdgeInsets

    // MARK: Init

    init(style: Style = .prominent, insets: UIEdgeInsets = .zero) {
        self.style = style
        self.insets = insets
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView Methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateShadows()
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(backgroundView)
        backgroundView.addSubview(contentView)

        backgroundView.pinEdgesToSuperview(insets: insets)
        contentView.pinEdgesToSuperview()

        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.layer.cornerRadius = .backgroundCornerRadius

        updateShadows()
    }

    private func updateShadows() {
        switch UITraitCollection.colorTheme {
        case .light:
            backgroundView.dropShadow(with: style.shadowConfiguration.light)
        case .dark:
            backgroundView.dropShadow(with: style.shadowConfiguration.dark)
        }
    }
}

// MARK: - CardContainerView.Style + Templates

extension CardContainerView.Style {
    static var prominent: Self {
        Self(
            backgroundColor: ASDKColors.Background.elevation1.color,
            shadowConfiguration: ShadowConfiguration(light: .medium, dark: .clear)
        )
    }

    static var prominentOnElevation1: Self {
        Self(
            backgroundColor: ASDKColors.Background.elevation2.color,
            shadowConfiguration: ShadowConfiguration(light: .medium, dark: .clear)
        )
    }

    static var flat: Self {
        Self(
            backgroundColor: ASDKColors.Background.neutral1.color,
            shadowConfiguration: .clear
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let backgroundCornerRadius: CGFloat = 16
}
