//
//  LoaderTitleView+Ext.swift
//  popup
//
//  Created by Ivan Glushko on 21.11.2022.
//

import UIKit

extension LoaderTitleView: ActivityIndicatorDisplayable {

    /// Показать индикатор
    func showActivityIndicator(with style: ActivityIndicatorView.Style) {
        let activityIndicatorView = ActivityIndicatorView(style: style)
        activityIndicatorView.transform = CGAffineTransform(scaleX: .zero, y: .zero)

        let container = ViewHolder(base: activityIndicatorView)

        loaderHolderView.addSubview(container)
        container.makeEqualToSuperview()

        UIView.animate(withDuration: .scaleDuration) {
            activityIndicatorView.transform = .identity
        }

        activityIndicatorView.startAnimation(animated: true)
    }

    /// Скрыть индикатор
    func hideActivityIndicator() {
        let container = loaderHolderView.subviews.compactMap { $0 as? ViewHolder<ActivityIndicatorView> }.first
        let indicatorView = container?.base
        UIView.animate(withDuration: .scaleDuration, animations: {
            indicatorView?.alpha = .zero
        }, completion: { _ in
            container?.removeFromSuperview()
        })
    }
}

extension LoaderTitleView: Animatable {

    func configure(_ config: Configuration) {
        titleLabelView.configure(config.title)
        config.getLoaderAnimatable = { self }
        startAnimating()
    }

    func startAnimating() {
        stopAnimating()
        showActivityIndicator(with: .tinkoffYellow)
    }

    func stopAnimating() {
        hideActivityIndicator()
    }
}

extension LoaderTitleView {

    struct Constants {

        struct Loader {
            static let size = CGSize(width: 34, height: 34)
            static let inset: CGFloat = 3
        }

        struct Label {
            static let leftInset: CGFloat = 15
            static let rightInset: CGFloat = 3
        }
    }
}

extension LoaderTitleView {

    final class Configuration {
        let title: UILabel.Configuration
        fileprivate(set) var getLoaderAnimatable: () -> Animatable? = { nil }

        init(title: UILabel.Configuration) {
            self.title = title
        }
    }
}

private extension ActivityIndicatorView.Style {

    static var tinkoffYellow: Self {
        ActivityIndicatorView.Style(
            lineColor: ASDKColors.tinkoffYellow,
            diameter: 30
        )
    }
}
