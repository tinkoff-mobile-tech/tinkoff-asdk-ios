//
//  MainFormOrderDetailsView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.01.2023.
//

import UIKit

final class MainFormOrderDetailsView: UIView {
    // MARK: Subviews

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

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = .contentStackSpacing
        return stack
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

    func update(with orderDetails: MainFormOrderDetails) {
        amountDescriptionLabel.text = orderDetails.amountDescription
        amountLabel.text = orderDetails.amount
        orderDescriptionLabel.text = orderDetails.orderDescription
    }

    // MARK: Initial Configuration

    private func setupView() {
        layoutContentStack()
        contentStack.addArrangedSubviews(amountDescriptionLabel, amountLabel, orderDescriptionLabel)
    }

    private func layoutContentStack() {
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: .contentStackVerticalInsets),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.contentStackVerticalInsets),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackVerticalInsets: CGFloat = 32
    static let contentStackSpacing: CGFloat = 8
}
