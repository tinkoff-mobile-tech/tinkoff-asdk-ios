//
//  PaymentActivityProcessingView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import Foundation

final class PaymentActivityProcessingView: UIView {
    // MARK: Subviews

    private lazy var activityIndicator = ActivityIndicatorView(style: .xlYellow)
    private lazy var titleLabel = UILabel(style: .headingM.set(alignment: .center))
    private lazy var descriptionLabel = UILabel(
        style: .bodyL.set(alignment: .center).set(textColor: ASDKColors.Text.secondary)
    )
    private lazy var primaryButton = Button()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(with state: PaymentActivityViewState.Processing) {
        titleLabel.text = state.title
        descriptionLabel.text = state.description
    }

    // MARK: Initial Configuration

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center

        stack.setCustomSpacing(.indicatorBottomInset, after: activityIndicator)
        stack.setCustomSpacing(.titleBottomInset, after: titleLabel)

        addSubview(stack)
        stack.pinEdgesToSuperview()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let indicatorBottomInset: CGFloat = 20
    static let titleBottomInset: CGFloat = 8
}
