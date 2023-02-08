//
//  MainFormOrderDetailsView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.01.2023.
//

import UIKit

final class MainFormOrderDetailsView: UIView {
    // MARK: Dependencies

    var presenter: IMainFormOrderDetailsViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Subviews

    private lazy var amountDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyLarge
        label.textColor = ASDKColors.Text.secondary.color
        label.textAlignment = .center
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .numbersExtraLarge
        label.textAlignment = .center
        return label
    }()

    private lazy var orderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyLarge
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

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(contentStack)
        contentStack.pinEdgesToSuperview()
        contentStack.addArrangedSubviews(amountDescriptionLabel, amountLabel, orderDescriptionLabel)
    }
}

// MARK: - IMainFormOrderDetailsViewInput

extension MainFormOrderDetailsView: IMainFormOrderDetailsViewInput {
    func set(amountDescription: String) {
        amountDescriptionLabel.text = amountDescription
    }

    func set(amount: String) {
        amountLabel.text = amount
    }

    func set(orderDescription: String?) {
        orderDescriptionLabel.text = orderDescription
    }
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackSpacing: CGFloat = 8
}
