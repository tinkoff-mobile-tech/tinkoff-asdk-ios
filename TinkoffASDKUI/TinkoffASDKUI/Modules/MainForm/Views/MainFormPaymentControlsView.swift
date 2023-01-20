//
//  MainFormPaymentControlsView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.01.2023.
//

import UIKit

final class MainFormPaymentControlsView: UIView {
    // MARK: Subviews

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .contentStackSpacing
        return stack
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
        layoutContentStack()
        layoutPayButton()
        setupPayButton()
        contentStack.addArrangedSubviews(payButton)
    }

    private func layoutContentStack() {
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func layoutPayButton() {
        payButton.heightAnchor.constraint(equalToConstant: .payButtonHeight).activated()
    }

    private func setupPayButton() {
        let configuration = Button.Configuration(
            data: Button.Data(
                text: .basic(normal: "Оплатить картой", highlighted: nil, disabled: nil),
                onTapAction: {}
            ),
            style: .primary
        )

        payButton.configure(configuration)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackSpacing: CGFloat = 12
    static let payButtonHeight: CGFloat = 56
}
