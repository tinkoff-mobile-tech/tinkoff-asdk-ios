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

    private lazy var payButton = Button()

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

        let configuration = Button.Configuration(
            data: Button.Data(
                text: .basic(normal: buttonTitle, highlighted: nil, disabled: nil),
                onTapAction: { [weak self] in
                    self?.delegate?.paymentControlsViewDidTapPayButton()
                }
            ),
            style: .primary
        )

        payButton.configure(configuration)
    }

    // MARK: Initial Configuration

    private func setupView() {
        layoutContentStack()
        layoutPayButton()
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
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackSpacing: CGFloat = 12
    static let payButtonHeight: CGFloat = 56
}
