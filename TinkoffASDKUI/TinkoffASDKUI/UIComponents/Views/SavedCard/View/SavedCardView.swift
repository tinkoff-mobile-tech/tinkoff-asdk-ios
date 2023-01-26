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

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = .contentStackDefaultSpacing
        return stack
    }()

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

    private lazy var cvcBackgroundContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .cvcFieldBackgroundCornerRadius
        view.backgroundColor = ASDKColors.Background.neutral1.color
        return view
    }()

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
        containerView.pinEdgesToSuperview()

        containerView.contentView.addSubview(contentStack)
        contentStack.pinEdgesToSuperview(insets: .contentStackInsets)
        contentStack.addArrangedSubviews(iconView, labelsStack, cvcBackgroundContainer)
        contentStack.setCustomSpacing(.contentStackIconTrailingSpacing, after: iconView)

        labelsStack.addArrangedSubviews(cardNameLabel, actionLabel)
        cvcBackgroundContainer.addSubview(cvcField)
        cvcField.pinEdgesToSuperview(insets: .cvcFieldInsets)

        NSLayoutConstraint.activate([
            cvcBackgroundContainer.widthAnchor.constraint(equalToConstant: CGSize.cvcBackgroundContainerSize.width),
            cvcBackgroundContainer.heightAnchor.constraint(equalToConstant: CGSize.cvcBackgroundContainerSize.height),
            iconView.widthAnchor.constraint(equalToConstant: CGSize.iconSize.width),
            iconView.heightAnchor.constraint(equalToConstant: CGSize.iconSize.height),
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
}

// MARK: ISavedPaymentCardViewInput

extension SavedCardView: ISavedCardViewInput {
    func update(with viewModel: SavedCardViewModel) {
        iconView.configure(model: viewModel.iconModel)
        cardNameLabel.text = viewModel.cardName
        actionLabel.text = viewModel.actionDescription
    }

    func showCVCField() {
        cvcBackgroundContainer.isHidden = false
    }

    func hideCVCField() {
        cvcBackgroundContainer.isHidden = true
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
