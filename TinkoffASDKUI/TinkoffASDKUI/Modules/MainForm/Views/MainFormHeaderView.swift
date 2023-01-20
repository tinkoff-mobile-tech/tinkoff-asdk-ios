//
//  MainFormHeaderView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormHeaderView: UIView {
    // MARK: Subviews

    private lazy var activityIndicator = ActivityIndicatorView(style: .xlYellow)

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    // MARK: Text Subviews

    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var amountDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = ASDKColors.Text.secondary.color
        label.textAlignment = .center
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var orderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = ASDKColors.Text.secondary.color
        label.textAlignment = .center
        return label
    }()

    private lazy var payButton = Button()

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
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: .indicatorVerticalInsets),
            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.indicatorVerticalInsets)
                .with(priority: .fittingSizeLevel),
        ])
    }
}

// MARK: - MainFormHeaderView + Estimated Height

extension MainFormHeaderView {
    var estimatedHeight: CGFloat {
        systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - Constants

private extension CGFloat {
    static let indicatorVerticalInsets: CGFloat = 32
    static let commonHorizontalInsets: CGFloat = 16
}
