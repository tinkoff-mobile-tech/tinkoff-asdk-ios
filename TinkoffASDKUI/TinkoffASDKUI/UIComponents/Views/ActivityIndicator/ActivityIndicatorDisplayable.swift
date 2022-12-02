//
//  ActivityIndicatorDisplayable.swift
//  popup
//
//  Created by Ivan Glushko on 14.11.2022.
//

import UIKit

/// Протокол с возможностью показа / скрытия индикатора
protocol ActivityIndicatorDisplayable {
    /// Показать индикатор
    func showActivityIndicator(with style: ActivityIndicatorView.Style)
    /// Скрыть индикатор
    func hideActivityIndicator()
}

/// Расширение протокола для возможности показывать индикатор
extension ActivityIndicatorDisplayable where Self: UIViewController {
    /// Показать индикатор
    func showActivityIndicator(with style: ActivityIndicatorView.Style) {
        let activityIndicatorView = ActivityIndicatorView(style: style)
        activityIndicatorView.transform = CGAffineTransform(scaleX: .zero, y: .zero)

        let container = ViewHolder(base: activityIndicatorView)

        view.addSubview(container)

        container.makeEqualToSuperview()
        UIView.animate(withDuration: .scaleDuration) {
            activityIndicatorView.transform = .identity
        }

        activityIndicatorView.startAnimation(animated: true)
    }

    /// Скрыть индикатор
    func hideActivityIndicator() {
        let container = view.subviews.compactMap { $0 as? ViewHolder<ActivityIndicatorView> }.first
        let indicatorView = container?.base
        UIView.animate(withDuration: .scaleDuration, animations: {
            indicatorView?.alpha = .zero
        }, completion: { _ in
            container?.removeFromSuperview()
        })
    }
}

// MARK: - Constants

extension TimeInterval {
    static let scaleDuration = 0.25 as TimeInterval
}
