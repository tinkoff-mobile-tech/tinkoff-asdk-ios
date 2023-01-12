//
//  CommonSheetView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 10.01.2023.
//

import UIKit

protocol CommonSheetViewDelegate: AnyObject {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState)
    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView)
    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView)
}

final class CommonSheetView: UIView {
    weak var delegate: CommonSheetViewDelegate?

    // MARK: Subviews

    private lazy var overlayView: UIView = {
        let view = PassthroughView()
        view.backgroundColor = ASDKColors.Background.elevation1.color
        view.alpha = .zero
        return view
    }()

    private lazy var activityIndicator = ActivityIndicatorView(style: .xlYellow)

    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        return iconView
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
    private lazy var secondaryButton = Button()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .contentStackInterItemSpacing
        return stack
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = .labelsStackInterItemSpacing
        return stack
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .buttonsStackInterItemSpacing
        return stack
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(delegate: CommonSheetViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = bounds
    }

    // MARK: CommonSheetView Updating

    func update(state: CommonSheetState) {
        showOverlay { [self] _ in
            updateStatusViews(with: state)
            updateLabels(with: state)
            updateButtons(with: state)
            layoutIfNeeded()
            delegate?.commonSheetView(self, didUpdateWithState: state)
            hideOverlay()
        }
    }

    // MARK: Initial Configuration

    private func setupView() {
        contentStack.addArrangedSubviews([iconView, activityIndicator, labelsStack, buttonsStack])
        contentStack.setCustomSpacing(.statusBottomSpacing, after: iconView)
        contentStack.setCustomSpacing(.statusBottomSpacing, after: activityIndicator)
        labelsStack.addArrangedSubviews([titleLabel, descriptionLabel])
        buttonsStack.addArrangedSubviews([primaryButton, secondaryButton])

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: .buttonsHeight),
            secondaryButton.heightAnchor.constraint(equalToConstant: .buttonsHeight),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: .contentStackVerticalInset),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .contentStackHorizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.contentStackHorizontalInset),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.contentStackVerticalInset)
                .with(priority: .fittingSizeLevel),
        ])

        addSubview(overlayView)
    }

    // MARK: Subviews Updating

    private func updateStatusViews(with state: CommonSheetState) {
        switch state.status {
        case .processing:
            activityIndicator.isHidden = false
            iconView.isHidden = true
        case .succeeded:
            iconView.image = Asset.TuiIcMedium.checkCirclePositive.image
            iconView.isHidden = false
            activityIndicator.isHidden = true
        case .failed:
            iconView.image = Asset.TuiIcMedium.crossCircle.image
            iconView.isHidden = false
            activityIndicator.isHidden = true
        }
    }

    private func updateLabels(with state: CommonSheetState) {
        titleLabel.text = state.title
        descriptionLabel.text = state.description
    }

    private func updateButtons(with state: CommonSheetState) {
        if let primaryButtonTitle = state.primaryButtonTitle {
            let buttonConfiguration = Button.Configuration(
                data: Button.Data(
                    text: .basic(normal: primaryButtonTitle, highlighted: nil, disabled: nil),
                    onTapAction: { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.commonSheetViewDidTapPrimaryButton(self)
                    }
                ),
                style: .primary
            )

            primaryButton.configure(buttonConfiguration)
            primaryButton.isHidden = false
        } else {
            primaryButton.isHidden = true
        }

        if let secondaryButtonTitle = state.secondaryButtonTitle {
            let buttonConfiguration = Button.Configuration(
                data: Button.Data(
                    text: .basic(normal: secondaryButtonTitle, highlighted: nil, disabled: nil),
                    onTapAction: { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.commonSheetViewDidTapSecondaryButton(self)
                    }
                ),
                style: .secondary
            )

            secondaryButton.configure(buttonConfiguration)
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }

        buttonsStack.isHidden = buttonsStack.arrangedSubviews.allSatisfy(\.isHidden)
    }

    // MARK: Overlay Animation

    private func showOverlay(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseIn],
            animations: { self.overlayView.alpha = 1 },
            completion: completion
        )
    }

    private func hideOverlay(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseOut],
            animations: { self.overlayView.alpha = .zero },
            completion: completion
        )
    }
}

// MARK: - PaymentActivityView + Estimated Height

extension CommonSheetView {
    var estimatedHeight: CGFloat {
        systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - Constants

private extension CGFloat {
    static let contentStackVerticalInset: CGFloat = 24
    static let contentStackHorizontalInset: CGFloat = 16
    static let contentStackInterItemSpacing: CGFloat = 24
    static let statusBottomSpacing: CGFloat = 20
    static let labelsStackInterItemSpacing: CGFloat = 8
    static let labelsStackBottomSpacing: CGFloat = 24
    static let buttonsStackInterItemSpacing: CGFloat = 12
    static let buttonsHeight: CGFloat = 56
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.3
}
