//
//  SkeletonView.swift
//  popup
//
//  Created by Ivan Glushko on 01.11.2022.
//

import UIKit

extension UIView {

    struct SkeletonSuperViewModel {
        let cornerRadiusStyle: SkeletonView.CornerRadiusStyle
        let color: UIColor.Dynamic

        func createModel(superview: UIView) -> SkeletonView.Model {
            let cornerRadius: CGFloat

            switch cornerRadiusStyle {
            case .round:
                cornerRadius = superview.frame.height * 0.5
            case .rounded:
                cornerRadius = superview.frame.height * 0.2
            case .sameAsSuperview:
                cornerRadius = superview.layer.cornerRadius
            case let .custom(radius):
                cornerRadius = radius
            }

            return SkeletonView.Model(
                color: color,
                cornerRadius: cornerRadius
            )
        }
    }

    @discardableResult
    func wrapInSkeletonView(model: SkeletonSuperViewModel) -> SkeletonView {
        let skeletonView = SkeletonView()
        addSubview(skeletonView)
        skeletonView.frame = frame
        skeletonView.configure(model: model.createModel(superview: self))
        skeletonView.makeEqualToSuperview()
        skeletonView.onFrameDidUpdate = { [weak self] skeletonView in
            guard let self = self else { return }
            skeletonView.configure(model: model.createModel(superview: self))
        }

        return skeletonView
    }

    /// recursively START animation in any view that is skeleton view
    func startSkeletonAnimation(type: SkeletonAnimationType, completion: (() -> Void)? = nil) {
        if let skeletonView = self as? SkeletonView {
            skeletonView.startAnimating(animationType: type, completion: completion)
        }

        for subview in subviews {
            subview.startSkeletonAnimation(type: type, completion: completion)
        }
    }

    /// recursively STOP animation in any view that is skeleton view
    func stopSkeletonAnimations() {
        if let skeletonView = self as? SkeletonView {
            skeletonView.stopAnimating()
        }

        for subview in subviews {
            subview.stopSkeletonAnimations()
        }
    }
}

final class SkeletonView: UIView {
    var onFrameDidUpdate: ((SkeletonView) -> Void)?

    override var frame: CGRect {
        didSet {
            notifyAboutFrameUpdateIfNeeded()
        }
    }

    private lazy var previousFrameValue = frame
    private let gradientLayer = CAGradientLayer()
    private var currentModel: Model?

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        notifyAboutFrameUpdateIfNeeded()
    }

    // MARK: - Public

    func configure(model: Model) {
        currentModel = model
        backgroundColor = model.color.color
        layer.cornerRadius = model.cornerRadius
        gradientLayer.cornerRadius = model.cornerRadius
    }

    func configure(model: UIView.SkeletonSuperViewModel) {
        configure(model: model.createModel(superview: self))
        onFrameDidUpdate = { passedSkeletonView in
            passedSkeletonView.configure(
                model: model.createModel(superview: passedSkeletonView)
            )
        }
    }

    func startAnimating(animationType: SkeletonAnimationType, completion: (() -> Void)? = nil) {
        stopAnimating()
        isHidden = false

        let targetLayer: CALayer
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
        }

        switch animationType {
        case .pulse:

            targetLayer = layer
            let animation = SkeletonAnimationBuilder()
                .makePulseAnimation(color: currentModel?.color ?? .basic)(targetLayer)
            targetLayer.add(animation, forKey: AnimationKey.pulseAnimation.rawValue)

        case let .waterfall(index, delay):

            targetLayer = layer
            let animation = SkeletonAnimationBuilder()
                .makeWaterfallAnimation(
                    viewCurrentAlpha: alpha,
                    duration: 1,
                    delay: Double(index) * delay
                )

            targetLayer.add(animation, forKey: AnimationKey.pulseAnimation.rawValue)

        case let .slidingGradient(direction):

            configureGradientLayer(gradientColor: currentModel?.color ?? .basic)
            targetLayer = gradientLayer
            let animation = SkeletonAnimationBuilder()
                .makeSlidingAnimation(withDirection: direction)(targetLayer)
            targetLayer.add(animation, forKey: AnimationKey.gradientAnimation.rawValue)
        }

        DispatchQueue.main.async { CATransaction.commit() }
    }

    func stopAnimating() {
        isHidden = true
        gradientLayer.removeFromSuperlayer()
        layer.removeAllAnimations()
        gradientLayer.removeAllAnimations()
    }

    // MARK: - Private

    private func notifyAboutFrameUpdateIfNeeded() {
        if frame != previousFrameValue {
            previousFrameValue = frame
            gradientLayer.frame.size = layer.frame.size
            onFrameDidUpdate?(self)
        }
    }

    private func configureGradientLayer(gradientColor: UIColor.Dynamic) {
        gradientLayer.colors = [
            gradientColor.color.cgColor,
            gradientColor.oppositeColor.withAlphaComponent(0.3).cgColor,
        ]
        gradientLayer.removeFromSuperlayer()
        layer.addSublayer(gradientLayer)
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}

extension SkeletonView {

    enum CornerRadiusStyle {
        case round
        case rounded
        case sameAsSuperview
        case custom(radius: CGFloat)
    }

    struct Model {
        let color: UIColor.Dynamic
        let cornerRadius: CGFloat
    }

    enum State {
        case hidden
        case visible
        case animating
    }

    enum AnimationKey: String {
        case gradientAnimation
        case pulseAnimation
    }
}

extension Array where Element == SkeletonView {

    func configure(model: SkeletonView.Model) {
        forEach { skeletonView in
            skeletonView.configure(model: model)
        }
    }

    func configure(model: UIView.SkeletonSuperViewModel) {
        forEach { skeletonView in
            skeletonView.configure(model: model)
        }
    }
}

extension Array where Element == UIView {
    @discardableResult
    func wrapInSkeletonView(model: UIView.SkeletonSuperViewModel) -> [SkeletonView] {
        return map { view in
            view.wrapInSkeletonView(model: model)
        }
    }
}
