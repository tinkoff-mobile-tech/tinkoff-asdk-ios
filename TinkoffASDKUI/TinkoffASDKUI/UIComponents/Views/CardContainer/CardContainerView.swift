//
//  CardContainerView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import UIKit

final class CardContainerView: UIView {
    // MARK: Style

    struct Style {
        let backgroundColor: UIColor
        let shadowConfiguration: ShadowConfiguration
    }

    // MARK: Subviews

    private(set) lazy var contentView = UIView()
    private lazy var backgroundView = UIView()

    // MARK: Dependencies

    private let style: Style
    private let insets: UIEdgeInsets
    private let onTap: VoidBlock?

    // MARK: State

    private var isHighlighted = false {
        didSet {
            apply(highlighted: isHighlighted)
        }
    }

    // MARK: Init

    init(
        style: Style = .prominent,
        insets: UIEdgeInsets = .zero,
        onTap: VoidBlock? = nil
    ) {
        self.style = style
        self.insets = insets
        self.onTap = onTap
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView Methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyShadows()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        var movingFrame = bounds.applying(transform.inverted())
        movingFrame.center = bounds.center
        isHighlighted = touches.contains {
            movingFrame.contains($0.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isHighlighted {
            isHighlighted = false
            onTap?()
        }
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(backgroundView)
        backgroundView.addSubview(contentView)

        backgroundView.pinEdgesToSuperview(insets: insets)
        contentView.pinEdgesToSuperview()

        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.layer.cornerRadius = .backgroundCornerRadius

        applyShadows()
    }

    // MARK: Updating

    private func applyShadows() {
        backgroundView.dropShadow(configuration: style.shadowConfiguration)
    }

    private func apply(highlighted: Bool) {
        let animations = {
            self.backgroundView.transform = highlighted ? .highlighted : .identity
        }

        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut],
            animations: animations
        )
    }
}

// MARK: - CardContainerView.Style + Templates

extension CardContainerView.Style {
    /// Стиль с цветом фона `elevation1` и тенью `medium`
    /// для использования на основных экранах с цветом `base`
    static var prominent: Self {
        Self(
            backgroundColor: ASDKColors.Background.elevation1.color,
            shadowConfiguration: ShadowConfiguration(light: .medium, dark: .clear)
        )
    }

    /// Стиль с цветом фона `elevation2` и тенью `small`
    /// для использования на основных экранах с цветом `elevation1`
    static var prominentOnElevation1: Self {
        Self(
            backgroundColor: ASDKColors.Background.elevation2.color,
            shadowConfiguration: ShadowConfiguration(light: .small, dark: .clear)
        )
    }

    /// Стиль с цветом фона `neutral1` без тени
    static var flat: Self {
        Self(
            backgroundColor: ASDKColors.Background.neutral1.color,
            shadowConfiguration: .clear
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let backgroundCornerRadius: CGFloat = 16
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.1
}

private extension CGAffineTransform {
    static let highlighted = CGAffineTransform(scaleX: 0.95, y: 0.95)
}
