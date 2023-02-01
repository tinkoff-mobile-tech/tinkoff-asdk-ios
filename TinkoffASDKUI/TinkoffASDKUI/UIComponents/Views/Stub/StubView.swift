//
//  StubView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.12.2022.
//

import UIKit

/// Вью для показа фулскрин заглушек
final class StubView: UIView {

    private(set) var configuration: Configuration = .empty

    // MARK: - UI

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let button = Button()

    private var layout: Layout?

    // MARK: - Init

    init(layout: Layout, availableWidth: CGFloat = UIScreen.main.bounds.width) {
        self.layout = layout
        super.init(frame: CGRect(x: 0, y: 0, width: availableWidth, height: 0))
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    @discardableResult
    func getContentHeight() -> CGSize {
        layoutIfNeeded()
        frame.size.height = button.frame.maxY
        return CGSize(width: frame.width, height: button.frame.maxY)
    }

    // MARK: - Private

    private func setupViews() {
        [iconImageView, titleLabel, subtitleLabel, button]
            .forEach { addSubview($0) }
    }

    private func setupConstraints() {
        assert(layout != nil)
        guard let layoutProvider = layout else { return }

        iconImageView.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor),
                view.centerXAnchor.constraint(equalTo: view.forcedSuperview.centerXAnchor),
            ] + view.size(layoutProvider.icon.size)
        }

        titleLabel.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: layoutProvider.title.topInset),
                view.centerXAnchor.constraint(equalTo: view.forcedSuperview.centerXAnchor),
            ] + view.makeLeftAndRightEqualToSuperView(inset: layoutProvider.title.horizontalInsets)
        }

        subtitleLabel.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: layoutProvider.subtitle.topInset),
                view.centerXAnchor.constraint(equalTo: view.forcedSuperview.centerXAnchor),
            ] + view.makeLeftAndRightEqualToSuperView(inset: layoutProvider.subtitle.horizontalInsets)
        }

        button.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: layoutProvider.button.topInset),
                view.centerXAnchor.constraint(equalTo: view.forcedSuperview.centerXAnchor),
            ]
        }
    }

    private func tuneConstraintsForEmptyContent(configuration: Configuration) {
        if case let UILabel.Content.plain(text, _) = configuration.title.content,
           text?.isEmpty ?? true {
            subtitleLabel.parsedConstraints.forEach {
                switch $0.kind {
                case .top:
                    $0.constraint.constant = .zero
                default: break
                }
            }
        }

        if case let UILabel.Content.plain(text, _) = configuration.subtitle.content,
           text?.isEmpty ?? true {
            button.parsedConstraints.forEach {
                switch $0.kind {
                case .top:
                    $0.constraint.constant = .zero
                default: break
                }
            }
        }
    }
}

extension StubView: ConfigurableItem {

    func configure(with configuration: Configuration) {
        iconImageView.configure(with: configuration.icon)
        titleLabel.configure(configuration.title)
        subtitleLabel.configure(configuration.subtitle)
        button.configure(configuration.button, animated: false)
        button.onTapAction = configuration.buttonAction
        // handling empty content cases
        tuneConstraintsForEmptyContent(configuration: configuration)
    }

    struct Configuration {
        let icon: UIImageView.Configuration
        let title: UILabel.Configuration
        let subtitle: UILabel.Configuration
        let button: Button.Configuration
        let buttonAction: VoidBlock

        static var empty: Self {
            Self(icon: .empty, title: .empty, subtitle: .empty, button: .empty, buttonAction: {})
        }
    }
}

extension StubView {
    struct Layout {
        var icon = Icon()
        var title = Title()
        var subtitle = Subtitle()
        var button = Button()

        struct Icon {
            var size = CGSize(width: 128, height: 128)
        }

        struct Title {
            var topInset: CGFloat = 24
            var horizontalInsets: CGFloat = 42.5
        }

        struct Subtitle {
            var topInset: CGFloat = 8
            var horizontalInsets: CGFloat = 42.5
        }

        struct Button {
            var topInset: CGFloat = 24
            var insets = UIEdgeInsets(vertical: 0, horizontal: 0)
        }
    }
}
