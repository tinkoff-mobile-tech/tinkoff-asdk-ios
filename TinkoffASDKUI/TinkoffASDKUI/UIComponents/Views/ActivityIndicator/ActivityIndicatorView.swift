//
//  dsfsadf.swift
//  popup
//
//  Created by Ivan Glushko on 14.11.2022.
//

import UIKit

/// Индикатор активности
final class ActivityIndicatorView: UIView, Stylable {

    /// Флаг активности анимации
    private(set) var isAnimating = false

    // Private/Computed
    private lazy var circle: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = style?.width ?? Constants.Layout.width
        layer.addSublayer(shapeLayer)
        setNeedsLayout()

        return shapeLayer
    }()

    // MARK: - Lifecycle

    init(style: Style = Style()) {
        super.init(frame: .zero)

        accessibilityIdentifier = String(describing: ActivityIndicatorView.self)
        apply(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = style?.padding ?? Constants.Layout.padding
        let originSize = (padding - size.height) / 2
        let widthHeight = size.height - padding
        let ovalRect = CGRect(
            origin: CGPoint(x: originSize, y: originSize),
            size: CGSize(width: widthHeight, height: widthHeight)
        )

        circle.path = UIBezierPath(ovalIn: ovalRect).cgPath
        circle.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAnimation(animated: false)
        } else {
            startAnimation(animated: false)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                circle.strokeColor = style?.lineColor.cgColor
            }
        }
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        size
    }

    // MARK: - Public

    /// Показывает индикатор
    func startAnimation(animated: Bool) {
        defer { startAnimation() }

        let animations = {
            self.circle.opacity = 1
        }
        guard animated else {
            animations()
            return
        }

        UIView.animate(
            withDuration: Constants.Animation.duration300ms,
            animations: animations
        )
    }

    /// Скрывает индикатор
    func stopAnimation(animated: Bool) {
        let animations = {
            self.circle.opacity = 0
        }
        let completion = { (isFinished: Bool) in
            guard isFinished else { return }

            self.circle.removeAllAnimations()
            self.isAnimating = false
        }

        guard animated else {
            animations()
            completion(true)
            return
        }

        UIView.animate(
            withDuration: Constants.Animation.duration300ms,
            animations: animations,
            completion: completion
        )
    }

    // MARK: - Private

    private func startAnimation() {
        guard !isAnimating else { return }

        startStrokeAnimation()
        startRotationAnimation()
        isAnimating = true
    }

    private func startStrokeAnimation() {
        guard circle.animation(forKey: Constants.Animation.strokeAnimation) == nil else { return }

        let forwardStrokeAnimation = CABasicAnimation(keyPath: Constants.Animation.layerStrokeEndAnimation)
        forwardStrokeAnimation.duration = Constants.Animation.duration3s / 2
        forwardStrokeAnimation.fromValue = 0
        forwardStrokeAnimation.toValue = 1

        let backwardStrokeAnimation = CABasicAnimation(keyPath: Constants.Animation.layerStrokeStartAnimation)
        backwardStrokeAnimation.duration = Constants.Animation.duration3s / 2
        backwardStrokeAnimation.fromValue = 0
        backwardStrokeAnimation.toValue = 1
        backwardStrokeAnimation.beginTime = Constants.Animation.duration3s / 2

        let group = CAAnimationGroup()
        group.animations = [forwardStrokeAnimation, backwardStrokeAnimation]
        group.repeatCount = .infinity
        group.duration = Constants.Animation.duration3s
        group.isRemovedOnCompletion = false

        circle.add(group, forKey: Constants.Animation.strokeAnimation)
    }

    private func startRotationAnimation() {
        guard circle.animation(forKey: Constants.Animation.rotationAnimation) == nil else { return }

        let rotationAnimation = CABasicAnimation(keyPath: Constants.Animation.layerTransformRotationZAnimation)
        rotationAnimation.fromValue = -Double.pi * 0.5
        rotationAnimation.toValue = Double.pi * 1.5
        rotationAnimation.duration = Constants.Animation.duration3s * 2 / Constants.Animation.rotationMultiplier
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false

        circle.add(rotationAnimation, forKey: Constants.Animation.rotationAnimation)
    }

    // MARK: - TCSStylable

    var style: Style?

    func apply(style: Style) {
        self.style = style

        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius ?? Constants.Layout.cornerRadius
        circle.strokeColor = style.lineColor.cgColor
        circle.lineCap = style.lineCap

        if let shadow = style.shadow {
            dropShadow(with: shadow)
        }
    }

    // MARK: - Style

    struct Style: Equatable {
        static var standart: ActivityIndicatorView.Style {
            ActivityIndicatorView.Style()
        }

        static var xlYellow: ActivityIndicatorView.Style {
            ActivityIndicatorView.Style(
                lineColor: ASDKColors.Foreground.brandTinkoffAccent,
                diameter: 72,
                width: 4
            )
        }

        var backgroundColor: UIColor
        var lineColor: UIColor
        var cornerRadius: CGFloat?
        var padding: CGFloat?
        var diameter: Double
        var width: CGFloat
        let shadow: ShadowStyle?
        let lineCap: CAShapeLayerLineCap

        init(
            backgroundColor: UIColor = .clear,
            lineColor: UIColor = .black,
            cornerRadius: CGFloat? = nil,
            padding: CGFloat? = nil,
            diameter: Double = 20,
            width: CGFloat = 2,
            shadow: ShadowStyle? = nil,
            lineCap: CAShapeLayerLineCap = .round
        ) {
            self.backgroundColor = backgroundColor
            self.lineColor = lineColor
            self.cornerRadius = cornerRadius
            self.diameter = diameter
            self.padding = padding
            self.width = width
            self.shadow = shadow
            self.lineCap = lineCap
        }
    }
}

private enum Constants {
    /// Константы для анимации
    enum Animation {
        static let strokeAnimation = "strokeAnimation"
        static let rotationAnimation = "rotationAnimation"

        static let layerStrokeStartAnimation = "strokeStart"
        static let layerStrokeEndAnimation = "strokeEnd"
        static let layerTransformRotationZAnimation = "transform.rotation.z"

        static let duration300ms: Double = 0.3
        static let duration3s: Double = 3

        static let rotationMultiplier: Double = 3
    }

    /// Константы для лэйаута
    enum Layout {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 0
        static let radius: Double = 12
        static let width: CGFloat = 2
        static let size = CGSize(width: radius * 2, height: radius * 2)
    }
}

private extension ActivityIndicatorView {
    var size: CGSize {
        guard let diameter = style?.diameter else { return Constants.Layout.size }

        let padding = style?.padding ?? Constants.Layout.padding
        let widthHeight = diameter + Double(padding)

        return CGSize(width: widthHeight, height: widthHeight)
    }
}
