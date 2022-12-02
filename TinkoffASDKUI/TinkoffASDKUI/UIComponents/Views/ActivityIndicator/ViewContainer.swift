//
//  ViewContainer.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 01.12.2022.
//

import Foundation

final class ViewContainer: UIView, ConfigurableItem {

    private(set) var configuration = Configuration(
        content: UIView(),
        layoutStrategy: .makeEqualToSuperview(insets: .zero)
    )

    func configure(with configuration: Configuration) {
        subviews.forEach { $0.removeFromSuperview() }

        self.configuration = configuration
        backgroundColor = configuration.backgroundColor
        addSubview(configuration.content)

        switch configuration.layoutStrategy {
        case let .makeEqualToSuperview(insets):
            configuration.content.makeEqualToSuperview(insets: insets)
        case let .custom(layout):
            layout(configuration.content)
        }
    }

    func updateEdge(insets: UIEdgeInsets) {
        configuration.content.constraintUpdater.updateEdgeInsets(insets: insets)
    }
}

extension ViewContainer {

    struct Configuration {
        let content: UIView
        let layoutStrategy: LayoutStrategy
        var backgroundColor: UIColor = .clear
    }

    enum LayoutStrategy {
        case custom((_ view: UIView) -> Void)
        case makeEqualToSuperview(insets: UIEdgeInsets)
    }
}
