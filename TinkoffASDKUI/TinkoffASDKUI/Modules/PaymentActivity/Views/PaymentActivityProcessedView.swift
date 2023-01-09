//
//  PaymentActivityLoadedView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.12.2022.
//

import UIKit

protocol PaymentActivityProcessedViewDelegate: AnyObject {
    func paymentActivityProcessedViewDidTapPrimaryButton(_ view: PaymentActivityProcessedView)
}

final class PaymentActivityProcessedView: UIView {
    weak var delegate: PaymentActivityProcessedViewDelegate?

    // MARK: UI

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ASDKColors.Text.primary.color
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = ASDKColors.Text.secondary.color
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var primaryButton = Button()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(delegate: PaymentActivityProcessedViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(with state: PaymentActivityViewState.Processed) {
        imageView.image = state.image
        titleLabel.text = state.title
        descriptionLabel.text = state.description

        let buttonConfiguration = Button.Configuration(
            data: Button.Data(
                text: .basic(normal: state.primaryButtonTitle, highlighted: nil, disabled: nil),
                onTapAction: { [weak self] in self?.primaryButtonDidTap() }
            ),
            style: .primary
        )
        primaryButton.configure(buttonConfiguration)
    }

    // MARK: Initial Configuration

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, descriptionLabel, primaryButton])
        stack.axis = .vertical
        stack.setCustomSpacing(.imageBottomInset, after: imageView)
        stack.setCustomSpacing(.titleBottomInset, after: titleLabel)
        stack.setCustomSpacing(.descriptionBottomInset, after: descriptionLabel)

        addSubview(stack)
        stack.pinEdgesToSuperview()

        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])
    }

    // MARK: Events

    private func primaryButtonDidTap() {
        delegate?.paymentActivityProcessedViewDidTapPrimaryButton(self)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let imageBottomInset: CGFloat = 20
    static let titleBottomInset: CGFloat = 8
    static let descriptionBottomInset: CGFloat = 24
    static let buttonHeight: CGFloat = 56
}
