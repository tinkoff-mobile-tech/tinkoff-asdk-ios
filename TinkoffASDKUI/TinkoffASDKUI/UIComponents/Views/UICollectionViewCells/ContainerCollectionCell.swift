//
//  ContainerCollectionCell.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 10.01.2023.
//

import UIKit

final class ContainerCollectionCell: UICollectionViewCell {

    var shouldHighlight = true

    override var isHighlighted: Bool {
        didSet {
            guard shouldHighlight else { return }
            apply(highlighted: isHighlighted)
        }
    }

    private var clientContentView: UIView?

    // MARK: - Private

    private func setupViews() {}

    private func apply(highlighted: Bool) {
        UIView.transition(
            with: self,
            duration: .highlightAnimationDuration,
            options: .transitionCrossDissolve
        ) {
            self.contentView.backgroundColor = highlighted
                ? ASDKColors.Background.highlight.color
                : .clear
        }
    }
}

// MARK: - Public

extension ContainerCollectionCell {

    func setContent(view: UIView, insets: UIEdgeInsets = .zero) {
        guard clientContentView !== view else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.pinEdgesToSuperview(insets: insets)
        clientContentView = view
    }

    func setContent(view: UIView, customLayout: (UIView) -> Void) {
        guard clientContentView !== view else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        customLayout(view)
        clientContentView = view
    }
}
