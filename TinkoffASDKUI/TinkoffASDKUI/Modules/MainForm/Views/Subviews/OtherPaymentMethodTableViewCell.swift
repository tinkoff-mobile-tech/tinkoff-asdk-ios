//
//  OtherPaymentMethodTableViewCell.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 06.02.2023.
//

import Foundation

final class OtherPaymentMethodTableViewCell: UITableViewCell {
    // MARK: Subviews

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyLarge
        label.textColor = ASDKColors.Text.primary.color
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .uiSmall
        label.textColor = ASDKColors.Text.secondary.color
        return label
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = .labelsSpacing
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = .contentStackSpacing
        return stack
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableViewCell Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
    }

    // MARK: View Updating

    func update(with model: OtherPaymentMethodViewModel) {
        avatarImageView.image = model.avatarImage
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }

    // MARK: Initial Configuration

    private func setupView() {
        contentView.addSubview(contentStack)
        contentStack.pinEdgesToSuperview(insets: .contentStackInsets)
        contentStack.addArrangedSubviews(avatarImageView, labelsStack)
        labelsStack.addArrangedSubviews(titleLabel, descriptionLabel)

        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: .avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: .avatarSize),
        ])
        accessoryType = .disclosureIndicator
    }
}

// MARK: - Constants

private extension CGFloat {
    static let labelsSpacing: CGFloat = 4
    static let contentStackSpacing: CGFloat = 16
    static let avatarSize: CGFloat = 40
}

private extension UIEdgeInsets {
    static let contentStackInsets = UIEdgeInsets(vertical: 8, horizontal: 16)
}
