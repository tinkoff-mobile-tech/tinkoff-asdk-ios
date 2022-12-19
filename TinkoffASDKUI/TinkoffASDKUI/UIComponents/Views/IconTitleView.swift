//
//  IconTitleView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 15.12.2022.
//

import UIKit

final class IconTitleView: UIView {

    typealias Cell = CollectionCell<IconTitleView>

    private(set) var configuration: Configuration = .empty

    // UI

    private let contentView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupViews() {
        addSubview(contentView)
        contentView.clipsToBounds = true
        contentView.makeEqualToSuperview()

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        iconImageView.makeConstraints { view in
            view.size(.zero) +
                [
                    view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor),
                    view.leftAnchor.constraint(equalTo: view.forcedSuperview.leftAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: view.forcedSuperview.bottomAnchor),
                ]
        }

        titleLabel.makeConstraints { view in
            [
                view.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
                view.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: .zero),
                view.rightAnchor.constraint(equalTo: view.forcedSuperview.rightAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: view.forcedSuperview.bottomAnchor),
            ]
        }
    }

    private func getHeight() -> CGFloat {
        let verticalInsets = configuration.contentInsets.vertical
        let iconHeight = configuration.iconSize.height
        return verticalInsets + iconHeight
    }
}

extension IconTitleView: ConfigurableItem {

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        updateConstraintInsets()
        frame.size.height = getHeight()
        iconImageView.configure(with: configuration.icon)
        titleLabel.configure(configuration.title)
    }

    private func updateConstraintInsets() {

        contentView.constraintUpdater.updateEdgeInsets(insets: configuration.contentInsets)

        iconImageView.parsedConstraints.forEach { parsedConstraint in
            switch parsedConstraint.kind {
            case .height:
                parsedConstraint.constraint.constant = configuration.iconSize.height
            case .width:
                parsedConstraint.constraint.constant = configuration.iconSize.width
            default:
                break
            }
        }

        titleLabel.parsedConstraints.forEach { parsedConstraint in
            switch parsedConstraint.kind {
            case .left:
                parsedConstraint.constraint.constant = configuration.spacing
            default:
                break
            }
        }
    }
}

extension IconTitleView: Configurable, Reusable {

    func update(with configuration: Configuration) {
        configure(with: configuration)
    }

    func prepareForReuse() {}
}

extension IconTitleView {

    struct Configuration {
        let icon: UIImageView.Configuration
        let title: UILabel.Configuration
        let iconSize: CGSize
        let spacing: CGFloat
        let contentInsets: UIEdgeInsets

        static func buildAddCardButton(icon: UIImage?, text: String?) -> Self {
            Self(
                icon: UIImageView.Configuration(
                    image: icon,
                    contentMode: .scaleAspectFit
                ),
                title: UILabel.Configuration(content: .plain(text: text, style: .bodyL())),
                iconSize: CGSize(width: 40, height: 40),
                spacing: 16,
                contentInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            )
        }

        static var empty: Self {
            Self(
                icon: .empty,
                title: .empty,
                iconSize: .zero,
                spacing: .zero,
                contentInsets: .zero
            )
        }
    }
}
