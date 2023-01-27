//
//  SavedCardView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.01.2023.
//

import UIKit

final class SavedCardView: UIView {
    // MARK: Dependencies

    var presenter: ISavedCardViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Content Container Subviews

    private lazy var containerView = CardContainerView(
        style: .prominentOnElevation1,
        onTap: { [weak self] in self?.presenter?.savedCardViewIsSelected() }
    )

    // MARK: Icon Subviews

    private lazy var iconView = DynamicIconCardView()

    // MARK: Label Subviews

    private lazy var cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = ASDKColors.Text.primary.color
        return label
    }()

    private lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = ASDKColors.Text.accent.color
        return label
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = .labelsStackSpacing
        return stack
    }()

    // MARK: CVC Field Subviews

    private lazy var cvcField = TextField()

    private lazy var cvcBackground: UIView = {
        let view = PassthroughView()
        view.layer.cornerRadius = .cvcFieldBackgroundCornerRadius
        view.backgroundColor = ASDKColors.Background.neutral1.color
        return view
    }()

    private lazy var accessoryView: UIView = {
        let view = UIView()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(accessoryViewTapped))
        view.addGestureRecognizer(recognizer)
        view.isHidden = true
        return view
    }()

    private lazy var accessoryViewWidthConstraint = accessoryView.widthAnchor.constraint(equalToConstant: .zero)

    // MARK: State

    private var textFieldListeners: [NSObject] = []

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
        setupLayout()
        configureCVCField(text: nil)
    }

    private func setupLayout() {
        addSubview(containerView)

        let contentView = containerView.contentView

        contentView.addSubview(iconView)
        contentView.addSubview(labelsStack)
        contentView.addSubview(accessoryView)
        accessoryView.addSubview(cvcBackground)
        cvcBackground.addSubview(cvcField)
        labelsStack.addArrangedSubviews(cardNameLabel, actionLabel)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        cvcBackground.translatesAutoresizingMaskIntoConstraints = false

        containerView.pinEdgesToSuperview()
        cvcField.pinEdgesToSuperview(insets: .cvcFieldInsets)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),

            iconView.widthAnchor.constraint(equalToConstant: CGSize.iconSize.width),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: CGSize.iconSize.height),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            labelsStack.trailingAnchor.constraint(equalTo: accessoryView.leadingAnchor).with(priority: .defaultLow),

            accessoryViewWidthConstraint,
            accessoryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            accessoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            cvcBackground.widthAnchor.constraint(equalToConstant: CGSize.cvcBackgroundContainerSize.width),
            cvcBackground.heightAnchor.constraint(equalToConstant: CGSize.cvcBackgroundContainerSize.height),
            cvcBackground.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
            cvcBackground.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -8),
        ])
    }

    private func configureCVCField(text: String?) {
        let maskingFactory = CardFieldMaskingFactory()

        let maskingDelegate = maskingFactory.buildForCvc(
            didFillMask: { [weak self] text, _ in
                self?.presenter?.savedCardView(didChangeCVC: text)
            },
            listenerStorage: &textFieldListeners
        )

        let textFieldConfiguration = TextField.TextFieldConfiguration.assembleWithRegularContentAndStyle(
            delegate: maskingDelegate,
            text: text,
            placeholder: .cvcFieldPlaceholder,
            eventHandler: { [weak self] event, _ in
                switch event {
                case .didBeginEditing:
                    self?.presenter?.savedCardViewDidBeginCVCFieldEditing()
                default:
                    break
                }
            },
            hasClearButton: false,
            keyboardType: .decimalPad,
            isSecure: true
        )

        let configuration = TextField.Configuration(
            textField: textFieldConfiguration,
            headerLabel: .validCVCHeader
        )

        cvcField.configure(with: configuration)
    }

    // MARK: Events

    @objc private func accessoryViewTapped() {
        cvcField.activate()
    }
}

// MARK: ISavedPaymentCardViewInput

extension SavedCardView: ISavedCardViewInput {
    func update(with viewModel: SavedCardViewModel) {
        iconView.configure(model: viewModel.iconModel)
        cardNameLabel.text = viewModel.cardName
        actionLabel.text = viewModel.actionDescription
    }

    func showCVCField() {
        accessoryView.isHidden = false
        accessoryViewWidthConstraint.constant = 83
    }

    func hideCVCField() {
        accessoryView.isHidden = true
        accessoryViewWidthConstraint.constant = .zero
    }

    func setCVCText(_ text: String) {
        configureCVCField(text: text)
    }

    func setCVCFieldValid() {
        cvcField.updateHeader(config: .validCVCHeader)
    }

    func setCVCFieldInvalid() {
        cvcField.updateHeader(config: .invalidCVCHeader)
    }

    func deactivateCVCField() {
        cvcField.deactivate()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let containerMinimalHeight: CGFloat = 64
    static let labelsStackSpacing: CGFloat = 4
    static let contentStackDefaultSpacing: CGFloat = 22
    static let contentStackIconTrailingSpacing: CGFloat = 16
    static let cvcFieldBackgroundCornerRadius: CGFloat = 16
}

private extension CGSize {
    static let iconSize = CGSize(width: 40, height: 26)
    static let cvcBackgroundContainerSize = CGSize(width: 59, height: 48)
}

private extension UIEdgeInsets {
    static let cvcFieldInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
    static let contentStackInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8)
}

private extension String {
    static let cvcFieldHeader = "CVC"
    static let cvcFieldPlaceholder = "123"
}

private extension UILabel.Configuration {
    static var validCVCHeader: Self {
        Self(
            content: .plain(
                text: .cvcFieldHeader,
                style: .bodyL().set(textColor: ASDKColors.Text.secondary.color)
            )
        )
    }

    static var invalidCVCHeader: Self {
        Self(
            content: .plain(
                text: .cvcFieldHeader,
                style: .bodyL().set(textColor: ASDKColors.Foreground.negativeAccent)
            )
        )
    }
}
