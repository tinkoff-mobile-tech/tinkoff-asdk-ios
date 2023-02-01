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
    private(set) var configuration: Configuration2
    private(set) var loaderVisible = false

    // MARK: Subviews & Constraints

    private lazy var backgroundView = UIView()
    private lazy var control = UIControl()
    private lazy var contentStack = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var loader = ActivityIndicatorView()
    private lazy var loaderContainer = ViewHolder(base: loader)

    private lazy var preferredHeight = heightAnchor.constraint(equalToConstant: .zero)
    private lazy var contentTop = contentStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
    private lazy var contentLeading = contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
    private lazy var contentTrailing = contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    private lazy var contentBottom = contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)

    // MARK: Private State

    private var stateObservers: [NSKeyValueObservation] = []

    // MARK: Init

    init(configuration: Configuration2 = .empty, onTapAction: VoidBlock? = nil) {
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

    func configure(_ configuration: Configuration2, animated: Bool) {
        guard self.configuration != configuration else { return }

        self.configuration = configuration
        applyConfiguration(animated: animated)
    }

    func reconfigure(animated: Bool, _ configurationChangeHandler: (inout Configuration2) -> Void) {
        var configuration = self.configuration
        configurationChangeHandler(&configuration)
        configure(configuration, animated: animated)
    }

    func setLoaderVisible(_ loaderVisible: Bool, animated: Bool) {
        guard self.loaderVisible != loaderVisible else { return }

        self.loaderVisible = loaderVisible
        performUpdates(animated: animated, updates: updateLoaderVisibility)
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
        addSubview(backgroundView)
        addSubview(control)
        addSubview(contentStack)
        addSubview(loaderContainer)
        contentStack.axis = .horizontal
        contentStack.alignment = .center

        [backgroundView, contentStack, imageView, titleLabel].forEach {
            $0.isUserInteractionEnabled = false
        }
    }

    private func setupConstraints() {
        backgroundView.pinEdgesToSuperview()
        control.pinEdgesToSuperview()
        loaderContainer.pinEdgesToSuperview()
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
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

    private func performUpdates(animated: Bool, updates: @escaping VoidBlock) {
        guard animated else { return updates() }

        UIView.transition(
            with: self,
            duration: .defaultAnimationDuration,
            options: [.transitionCrossDissolve],
            animations: updates
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

        imageView.isHidden = configuration.icon == nil
        titleLabel.isHidden = configuration.title == nil
    }

    private func updateColorsForState() {
        titleLabel.textColor = configuration.style.foregroundColor.forState(control.state)
        imageView.tintColor = configuration.style.foregroundColor.forState(control.state)
        backgroundView.backgroundColor = configuration.style.backgroundColor.forState(control.state)
    }

    private func updateCorners() {
        backgroundView.layer.cornerRadius = configuration
            .contentSize
            .cornersStyle
            .cornerRadius(for: backgroundView.bounds)
    }

    private func updateLoaderVisibility() {
        contentStack.isHidden = loaderVisible
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

// MARK: - Button + Types

extension Button {
    static var defaultHeight: CGFloat { 56 }

    func startLoading() {}
    func stopLoading() {}
    func configure(_ configuration: Configuration) {}
    private func configureButton(data: Data) {}
    private func configureButton(style: Style) {}

    struct Data {
        enum Text {
            case basic(
                normal: String?,
                highlighted: String?,
                disabled: String?
            )
        }

        let text: Text?
        let onTapAction: () -> Void
    }

    struct Configuration {
        let data: Data
        let style: Style

        static var empty: Self {
            Self(data: Button.Data(text: nil, onTapAction: {}), style: .destructive)
        }
    }

    enum ActivityIndicatorState {
        case loading
        case normal
    }
}

// MARK: - Button.Style.Color + Helpers

private extension Button.Style2.Color {
    func forState(_ state: UIControl.State) -> UIColor {
        switch state {
        case .highlighted:
            return highlighted
        case .disabled:
            return disabled
        default:
            return normal
        }
    }
}

// MARK: - ActivityIndicatorView.Style + Helpers

private extension ActivityIndicatorView.Style {
    static func from(_ configuration: Button.Configuration2) -> ActivityIndicatorView.Style {
        ActivityIndicatorView.Style(
            lineColor: configuration.style.foregroundColor.normal,
            diameter: configuration.contentSize.activityIndicatorDiameter
        )
    }
}
