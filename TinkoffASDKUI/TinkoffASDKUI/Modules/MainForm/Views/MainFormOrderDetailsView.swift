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

    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
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

    func update(amountDescription: String, amount: String, orderDescription: String?) {
        amountDescriptionLabel.text = amountDescription
        amountLabel.text = amount
        orderDescriptionLabel.text = orderDescription
    }

    // MARK: Initial Configuration

    private func setupView() {
        textStack.addArrangedSubviews(amountDescriptionLabel, amountLabel, orderDescriptionLabel)
        addSubview(textStack)
        textStack.pinEdgesToSuperview()
    }
}
