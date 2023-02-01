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

    private(set) var configuration: Configuration

    // MARK: Subviews & Constraints

    private lazy var control = UIControl()
    private lazy var contentStack = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var loader = ActivityIndicatorView()
    private lazy var loaderContainer = ViewHolder(base: loader)

    private lazy var preferredHeight = control.heightAnchor.constraint(equalToConstant: .zero)
    private lazy var contentTop = contentStack.topAnchor.constraint(greaterThanOrEqualTo: control.topAnchor)
    private lazy var contentLeading = contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: control.leadingAnchor)
    private lazy var contentTrailing = contentStack.trailingAnchor.constraint(lessThanOrEqualTo: control.trailingAnchor)
    private lazy var contentBottom = contentStack.bottomAnchor.constraint(lessThanOrEqualTo: control.bottomAnchor)

    // MARK: Private State

    private var action: VoidBlock?
    private var stateObservers: [NSKeyValueObservation] = []

    // MARK: Init

    init(configuration: Configuration = .empty, action: VoidBlock? = nil) {
        self.configuration = configuration
        self.action = action
        super.init(frame: .zero)
        setupView()
        updateView()
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

    func configure(_ configuration: Configuration) {
        guard self.configuration != configuration else { return }
        self.configuration = configuration
        updateView()
    }

    func setTitle(_ title: String?) {
        guard configuration.title != title else { return }
        configuration.title = title
        updateContent()
        updateContentVisibility()
    }

    func setImage(_ image: UIImage?) {
        guard configuration.image != image else { return }
        configuration.image = image
        updateContent()
        updateContentVisibility()
    }

    func setStyle(_ style: Button.Style) {
        guard configuration.style != style else { return }
        configuration.style = style
        updateStyleForCurrentState()
    }

    func startLoading() {
        guard !configuration.isLoading else { return }
        configuration.isLoading = true
        updateLoaderVisibility()
        updateContentVisibility()
    }

    func stopLoading(animated: Bool = true) {
        guard configuration.isLoading else { return }
        configuration.isLoading = false
        updateLoaderVisibility()
        updateContentVisibility()
    }

    func setAction(_ action: VoidBlock?) {
        self.action = action
    }

    // MARK: Initial Configuration

    private func setupView() {
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

    // MARK: View Updating

    private func updateView() {
        updateStyleForCurrentState()
        updateContentSize()
        updateContent()
        updateContentPlacement()
        updateContentVisibility()
        updateLoaderVisibility()
    }

    private func updateStyleForCurrentState() {
        titleLabel.textColor = configuration.style.foregroundColor.forState(control.state)
        imageView.tintColor = configuration.style.foregroundColor.forState(control.state)
        control.backgroundColor = configuration.style.backgroundColor.forState(control.state)
        loader.apply(style: .from(configuration))
    }

    private func updateContentSize() {
        titleLabel.font = configuration.contentSize.titleFont
        contentStack.spacing = configuration.contentSize.imagePadding
        contentTop.constant = configuration.contentSize.contentInsets.top
        contentLeading.constant = configuration.contentSize.contentInsets.left
        contentTrailing.constant = -configuration.contentSize.contentInsets.right
        contentBottom.constant = -configuration.contentSize.contentInsets.bottom
        preferredHeight.constant = configuration.contentSize.preferredHeight
        loader.apply(style: .from(configuration))
        loader.setNeedsLayout()
        updateCorners()
    }

    private func updateContent() {
        titleLabel.text = configuration.title
        imageView.image = configuration.image
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
    }

    private func updateContentVisibility() {
        // Исправляет странные движения внутри стека во время анимации
        UIView.performWithoutAnimation {
            imageView.isHidden = configuration.image == nil || configuration.isLoading
            titleLabel.isHidden = configuration.title == nil || configuration.title?.isEmpty == true || configuration.isLoading
        }
    }

    private func updateLoaderVisibility() {
        loaderContainer.isHidden = !configuration.isLoading
    }

    private func updateCorners() {
        control.layer.cornerRadius = configuration
            .contentSize
            .cornersStyle
            .cornerRadius(for: control.bounds)
    }

    // MARK: Events

    @objc private func buttonTapped() {
        action?()
    }

    private func controlStateDidChange() {
        performUpdates(animated: true, updates: updateStyleForCurrentState)
    }

    // MARK: Animations

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
            duration: .animationDuration,
            options: [.transitionCrossDissolve],
            animations: updates,
            completion: { _ in completion?() }
        )
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
