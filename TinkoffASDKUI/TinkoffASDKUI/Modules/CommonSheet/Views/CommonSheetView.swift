//
//  CommonSheetView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 10.01.2023.
//

import UIKit

protocol ICommonSheetViewDelegate: AnyObject {
    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView)
    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView)
}

extension ICommonSheetViewDelegate {
    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {}
    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {}
}

final class CommonSheetView: PassthroughView {
    weak var delegate: ICommonSheetViewDelegate?

    // MARK: Subviews

    private lazy var overlayView: UIView = {
        let view = PassthroughView()
        view.backgroundColor = ASDKColors.Background.elevation1.color
        view.alpha = .zero
        return view
    }()

    private lazy var statusView = CommonSheetStatusView()

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

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = ASDKColors.Background.elevation1.color
        return view
    }()

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
    private lazy var contentBottomConstraint = contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        .with(priority: .fittingSizeLevel)

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(delegate: ICommonSheetViewDelegate) {
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
        backgroundView.frame = bounds
    }

    // MARK: CommonSheetView

    func set(state: CommonSheetState) {
        updateViews(with: state)
        layoutIfNeeded()
    }

    func showOverlay(animated: Bool = true, completion: VoidBlock? = nil) {
        let animations = { self.overlayView.alpha = 1 }

        guard animated else {
            animations()
            completion?()
            return
        }

        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseIn],
            animations: animations,
            completion: { _ in completion?() }
        )
    }

    func hideOverlay(animated: Bool = true, completion: VoidBlock? = nil) {
        let animations = { self.overlayView.alpha = .zero }

        guard animated else {
            animations()
            completion?()
            return
        }

        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseOut],
            animations: animations,
            completion: { _ in completion?() }
        )
    }

    // MARK: Initial Configuration

    private func setupView() {
        setupLayout()
        updateViews(with: CommonSheetState(status: .processing))
    }

    private func setupLayout() {
        addSubview(backgroundView)

        contentStack.addArrangedSubviews([statusView, labelsStack, buttonsStack])
        labelsStack.addArrangedSubviews([titleLabel, descriptionLabel])
        buttonsStack.addArrangedSubviews([primaryButton, secondaryButton])

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentTopConstraint,
            contentBottomConstraint,
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .contentHorizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.contentHorizontalInset),
            statusView.heightAnchor.constraint(equalToConstant: .statusViewHeight),
        ])

        addSubview(overlayView)
    }

    // MARK: Subviews Updating

    private func updateViews(with state: CommonSheetState) {
        updateStatusViews(with: state)
        updateLabels(with: state)
        updateButtons(with: state)
        updateContentLayout(with: state)
        updateContentStack(with: state)
        updateBackground(with: state)
    }

    private func updateStatusViews(with state: CommonSheetState) {
        switch state.status {
        case let .some(status):
            statusView.set(status: status)
            statusView.isHidden = false
        case .none:
            statusView.isHidden = true
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

    private func updateBackground(with state: CommonSheetState) {
        backgroundView.isHidden = state == .clear
    }

    private func updateContentStack(with state: CommonSheetState) {
        contentStack.isHidden = state == .clear
    }

    private func updateContentLayout(with state: CommonSheetState) {
        let hasContentAfterStatusViews = [
            state.title,
            state.description,
            state.primaryButtonTitle,
            state.secondaryButtonTitle,
        ].contains(where: \.hasText)

        let statusBottomSpacing: CGFloat = hasContentAfterStatusViews ? .statusBottomSpacing : .zero

        contentStack.setCustomSpacing(statusBottomSpacing, after: statusView)

        contentTopConstraint.constant = hasContentAfterStatusViews ? .defaultContentVerticalInset : .emptyContentTopInset
        contentBottomConstraint.constant = hasContentAfterStatusViews ? -.defaultContentVerticalInset : -.emptyContentBottomInset
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
    static let statusViewHeight: CGFloat = 72
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.3
}

// MARK: Optional + Helpers

private extension Optional where Wrapped == String {
    var hasText: Bool {
        guard let self = self else { return false }
        return !self.isEmpty
    }
}
