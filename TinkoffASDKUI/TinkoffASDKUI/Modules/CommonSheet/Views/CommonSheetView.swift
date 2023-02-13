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
        label.font = .headingMedium
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = ASDKColors.Text.secondary.color
        label.font = .bodyLarge
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var primaryButton = Button(
        configuration: Button.Configuration(style: .primaryTinkoff, contentSize: .basicLarge),
        action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.commonSheetViewDidTapPrimaryButton(self)
        }
    )

    private lazy var secondaryButton = Button(
        configuration: Button.Configuration(style: .secondary, contentSize: .basicLarge),
        action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.commonSheetViewDidTapSecondaryButton(self)
        }
    )

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .contentInterItemSpacing
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

    // MARK: Constraints

    private lazy var contentTopConstraint = contentStack.topAnchor.constraint(equalTo: topAnchor)
    private lazy var contentBottomConstraint = contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        .with(priority: .fittingSizeLevel)

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
            updateViews(with: state)
            layoutIfNeeded()
            delegate?.commonSheetView(self, didUpdateWithState: state)
            hideOverlay()
        }
    }

    // MARK: Initial Configuration

    private func setupView() {
        setupLayout()
        updateViews(with: CommonSheetState(status: .processing))
    }

    private func setupLayout() {
        contentStack.addArrangedSubviews([iconView, activityIndicator, labelsStack, buttonsStack])
        labelsStack.addArrangedSubviews([titleLabel, descriptionLabel])
        buttonsStack.addArrangedSubviews([primaryButton, secondaryButton])

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentTopConstraint,
            contentBottomConstraint,
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .contentHorizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.contentHorizontalInset),
        ])

        addSubview(overlayView)
    }

    // MARK: Subviews Updating

    private func updateViews(with state: CommonSheetState) {
        updateStatusViews(with: state)
        updateLabels(with: state)
        updateButtons(with: state)
        updateContentLayout(with: state)
    }

    private func updateStatusViews(with state: CommonSheetState) {
        switch state.status {
        case .processing:
            activityIndicator.isHidden = false
            iconView.isHidden = true
        case .succeeded:
            iconView.image = Asset.Illustrations.checkCirclePositive.image
            iconView.isHidden = false
            activityIndicator.isHidden = true
        case .failed:
            iconView.image = Asset.Illustrations.crossCircle.image
            iconView.isHidden = false
            activityIndicator.isHidden = true
        }
    }

    private func updateLabels(with state: CommonSheetState) {
        titleLabel.text = state.title
        titleLabel.isHidden = !state.title.hasText
        descriptionLabel.text = state.description
        descriptionLabel.isHidden = !state.description.hasText
        labelsStack.isHidden = labelsStack.arrangedSubviews.allSatisfy(\.isHidden)
    }

    private func updateButtons(with state: CommonSheetState) {
        primaryButton.setTitle(state.primaryButtonTitle)
        primaryButton.isHidden = !state.primaryButtonTitle.hasText
        secondaryButton.setTitle(state.secondaryButtonTitle)
        secondaryButton.isHidden = !state.secondaryButtonTitle.hasText
        buttonsStack.isHidden = buttonsStack.arrangedSubviews.allSatisfy(\.isHidden)
    }

    private func updateContentLayout(with state: CommonSheetState) {
        let hasContentAfterStatusViews = [
            state.title,
            state.description,
            state.primaryButtonTitle,
            state.secondaryButtonTitle,
        ].contains(where: \.hasText)

        let statusBottomSpacing: CGFloat = hasContentAfterStatusViews ? .statusBottomSpacing : .zero

        contentStack.setCustomSpacing(statusBottomSpacing, after: iconView)
        contentStack.setCustomSpacing(statusBottomSpacing, after: activityIndicator)

        contentTopConstraint.constant = hasContentAfterStatusViews ? .defaultContentVerticalInset : .emptyContentTopInset
        contentBottomConstraint.constant = hasContentAfterStatusViews ? -.defaultContentVerticalInset : -.emptyContentBottomInset
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

// MARK: - CommonSheetView + Estimated Height

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
    static let defaultContentVerticalInset: CGFloat = 24
    static let emptyContentTopInset: CGFloat = 36
    static let emptyContentBottomInset: CGFloat = 32
    static let contentHorizontalInset: CGFloat = 16
    static let contentInterItemSpacing: CGFloat = 24
    static let statusBottomSpacing: CGFloat = 20
    static let labelsStackInterItemSpacing: CGFloat = 8
    static let labelsStackBottomSpacing: CGFloat = 24
    static let buttonsStackInterItemSpacing: CGFloat = 12
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.3
}

// MARK: Optional + Helpers

private extension String? {
    var hasText: Bool {
        guard let self = self else { return false }
        return !self.isEmpty
    }
}
