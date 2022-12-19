//
//  SnackbarView.swift
//  popup
//
//  Created by Ivan Glushko on 17.11.2022.
//

import UIKit

/// Показывает бабл с информацией внутри. Умеет презентоваться снизу вверх.
final class SnackbarView: UIView, ShadowAvailable {

    /// Стандартный размер снекбара
    static var defaultSize: CGSize { Constants.defaultSize }

    override var intrinsicContentSize: CGSize { frame.size }

    private let contentView = UIView()

    // MARK: - Inits

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func hide() {
        removeFromSuperview()
    }

    // MARK: - Private

    private func setupViews() {
        contentView.clipsToBounds = true
        addSubview(contentView)
        contentView.makeEqualToSuperview()
    }
}

extension SnackbarView {

    func configure(with config: Configuration) {
        prepareForReuse()
        configureSnack(style: config.style)
        configureSnack(data: config.content)
        config.onDidConfigure?()
    }

    private func configureSnack(style: Style) {
        layer.masksToBounds = false
        layer.cornerRadius = style.cornerRadius
        contentView.layer.cornerRadius = style.cornerRadius
        contentView.backgroundColor = style.backgroundColor

        if let shadow = style.shadow {
            dropShadow(with: shadow)
        }
    }

    private func configureSnack(data: Content) {
        switch data {
        case let .view(subContentView, insets):
            contentView.addSubview(subContentView)
            subContentView.makeEqualToSuperview(insets: insets)
        case let .loader(config):
            let loaderView = LoaderTitleView()
            configureSnack(data: .view(contentView: loaderView, insets: Constants.insets))
            loaderView.configure(config)
        case .none:
            break
        }
    }

    private func prepareForReuse() {
        removeShadow()
        backgroundColor = nil
        layer.cornerRadius = .zero
        contentView.layer.cornerRadius = .zero
        contentView.backgroundColor = .clear
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension SnackbarView {

    enum State {
        case hidden
        case shown
    }

    struct Constants {
        static let anchorInset: CGFloat = 24
        static let defaultSize = CGSize(width: UIScreen.main.bounds.width - (2 * 16), height: 64)
        static let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
}

extension SnackbarView {

    struct Configuration {
        let content: Content
        let style: Style

        var onDidConfigure: (() -> Void)?
    }

    enum Content {
        case view(contentView: UIView, insets: UIEdgeInsets = .zero)
        case loader(configuration: LoaderTitleView.Configuration)
        case none
    }

    struct Style {
        var backgroundColor: UIColor?
        let cornerRadius: CGFloat
        let shadow: ShadowStyle?

        func set(backgroundColor: UIColor?) -> Self {
            var shadowCopy = self
            shadowCopy.backgroundColor = backgroundColor
            return shadowCopy
        }

        static var base: Self {
            Self(
                backgroundColor: UIColor.dynamicColor(
                    dynamic: UIColor.Dynamic(light: .white, dark: .lightGray)
                ),
                cornerRadius: 20,
                shadow: .medium
            )
        }
    }
}
