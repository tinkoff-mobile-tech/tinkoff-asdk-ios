//
//  MainFormPaymentControlsView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.01.2023.
//

import UIKit

protocol MainFormPaymentControlsViewDelegate: AnyObject {
    func paymentControlsViewDidTapPayButton()
}

final class MainFormPaymentControlsView: UIView {
    // MARK: Dependencies

    weak var delegate: MainFormPaymentControlsViewDelegate?

    // MARK: Subviews

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .contentStackSpacing
        return stack
    }()

    private lazy var payButton = Button(
        configuration: Button.Configuration(style: .primaryTinkoff, contentSize: .basicLarge, imagePlacement: .trailing),
        action: { [weak self] in self?.delegate?.paymentControlsViewDidTapPayButton() }
    )

    // MARK: Init

    convenience init(frame: CGRect = .zero, delegate: MainFormPaymentControlsViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(with viewModel: MainFormPaymentControlsViewModel) {
        let buttonTitle: String

        switch viewModel.buttonType {
        case let .primary(title):
            buttonTitle = title
        }

        payButton.setTitle(buttonTitle)
    }

    func set(payButtonEnabled: Bool) {
        payButton.isEnabled = payButtonEnabled
    }

    // MARK: Initial Configuration

    private func setupView() {
        layoutContentStack()
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
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackSpacing: CGFloat = 12
}
