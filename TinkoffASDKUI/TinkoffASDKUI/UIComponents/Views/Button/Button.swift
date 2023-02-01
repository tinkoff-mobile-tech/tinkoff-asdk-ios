//
//  Button.swift
//  ASDK
//
//  Created by Ivan Glushko on 15.11.2022.
//

import UIKit

final class Button: UIView {
    // MARK: Internal State

    var isEnabled: Bool {
        get { control.isEnabled }
        set { control.isEnabled = newValue }
    }

    var onTapAction: VoidBlock?
    private(set) var configuration: Configuration
    private(set) var loaderVisible = false

    // MARK: Subviews & Constraints

    private lazy var control = UIControl()
    private lazy var contentStack = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var loader = ActivityIndicatorView()
    private lazy var loaderContainer = ViewHolder(base: loader)

    private lazy var preferredHeight = heightAnchor.constraint(equalToConstant: .zero)
    private lazy var contentTop = contentStack.topAnchor.constraint(greaterThanOrEqualTo: control.topAnchor)
    private lazy var contentLeading = contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: control.leadingAnchor)
    private lazy var contentTrailing = contentStack.trailingAnchor.constraint(lessThanOrEqualTo: control.trailingAnchor)
    private lazy var contentBottom = contentStack.bottomAnchor.constraint(lessThanOrEqualTo: control.bottomAnchor)

    // MARK: Private State

    private var stateObservers: [NSKeyValueObservation] = []

    // MARK: Init

    init(configuration: Configuration = Configuration(), onTapAction: VoidBlock? = nil) {
        self.configuration = configuration
        self.onTapAction = onTapAction
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }

    // MARK: Button Methods

    func configure(_ configuration: Configuration, animated: Bool) {
        guard self.configuration != configuration else { return }

        self.configuration = configuration
        applyConfiguration(animated: animated)
    }

    func reconfigure(animated: Bool, _ configurationChangeHandler: (inout Configuration) -> Void) {
        let configuration = modify(configuration, configurationChangeHandler)
        configure(configuration, animated: animated)
    }

    func setLoaderVisible(_ loaderVisible: Bool, animated: Bool) {
        guard self.loaderVisible != loaderVisible else { return }

        self.loaderVisible = loaderVisible

        performUpdates(
            animated: animated,
            updates: loaderVisible ? updateContentPlacement : updateLoaderVisibility,
            completion: { [self] in
                performUpdates(
                    animated: animated,
                    updates: loaderVisible ? updateLoaderVisibility : updateContentPlacement
                )
            }
        )
    }

    // MARK: Initial Configuration

    private func setupView() {
        applyConfiguration(animated: false)
        setupViewHierarchy()
        setupConstraints()
        setupObservers()
        updateLoaderVisibility()
        control.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func setupViewHierarchy() {
        addSubview(control)
        control.addSubview(contentStack)
        control.addSubview(loaderContainer)
        control.clipsToBounds = true
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.isUserInteractionEnabled = false
    }

    private func setupConstraints() {
        control.pinEdgesToSuperview()
        loaderContainer.pinEdgesToSuperview()
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: control.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: control.centerYAnchor),
            contentTop,
            contentLeading,
            contentTrailing,
            contentBottom,
            preferredHeight,
        ])
    }

    private func setupObservers() {
        let changeHandler: (UIControl, NSKeyValueObservedChange<Bool>) -> Void = { [weak self] _, _ in
            self?.controlStateDidChange()
        }

        stateObservers = [
            control.observe(\.isHighlighted, changeHandler: changeHandler),
            control.observe(\.isEnabled, changeHandler: changeHandler),
        ]
    }

    // MARK: Subviews Updating

    private func applyConfiguration(animated: Bool) {
        updateLayoutConstants()
        loader.setNeedsLayout()

        performUpdates(animated: animated) { [self] in
            updateColorsForState()
            updateContent()
            loader.apply(style: .from(configuration))
            UIView.performWithoutAnimation(updateContentPlacement)
        }
    }

    private func performUpdates(
        animated: Bool,
        updates: @escaping VoidBlock,
        completion: VoidBlock? = nil
    ) {
        guard animated else {
            updates()
            completion?()
            return
        }

        UIView.transition(
            with: self,
            duration: .defaultAnimationDuration,
            options: [.transitionCrossDissolve, .curveEaseInOut],
            animations: updates,
            completion: { _ in completion?() }
        )
    }

    private func updateLayoutConstants() {
        contentTop.constant = configuration.contentSize.contentInsets.top
        contentLeading.constant = configuration.contentSize.contentInsets.left
        contentTrailing.constant = -configuration.contentSize.contentInsets.right
        contentBottom.constant = -configuration.contentSize.contentInsets.bottom

        preferredHeight.constant = configuration.contentSize.preferredHeight
        contentStack.spacing = configuration.contentSize.imagePadding
    }

    private func updateContent() {
        titleLabel.font = configuration.contentSize.titleFont
        titleLabel.text = configuration.title
        imageView.image = configuration.icon
    }

    private func updateContentPlacement() {
        contentStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        switch configuration.imagePlacement {
        case .leading:
            contentStack.addArrangedSubviews(imageView, titleLabel)
        case .trailing:
            contentStack.addArrangedSubviews(titleLabel, imageView)
        }

        contentStack.isHidden = loaderVisible
        imageView.isHidden = configuration.icon == nil
        titleLabel.isHidden = configuration.title == nil
    }

    private func updateColorsForState() {
        titleLabel.textColor = configuration.style.foregroundColor.forState(control.state)
        imageView.tintColor = configuration.style.foregroundColor.forState(control.state)
        control.backgroundColor = configuration.style.backgroundColor.forState(control.state)
    }

    private func updateCorners() {
        control.layer.cornerRadius = configuration
            .contentSize
            .cornersStyle
            .cornerRadius(for: control.bounds)
    }

    private func updateLoaderVisibility() {
        loaderContainer.isHidden = !loaderVisible
    }

    // MARK: Events

    @objc private func buttonTapped() {
        onTapAction?()
    }

    private func controlStateDidChange() {
        performUpdates(animated: true, updates: updateColorsForState)
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.15
}

// MARK: - ActivityIndicatorView.Style + Helpers

private extension ActivityIndicatorView.Style {
    static func from(_ configuration: Button.Configuration) -> ActivityIndicatorView.Style {
        ActivityIndicatorView.Style(
            lineColor: configuration.style.foregroundColor.normal,
            diameter: configuration.contentSize.activityIndicatorDiameter
        )
    }
}
