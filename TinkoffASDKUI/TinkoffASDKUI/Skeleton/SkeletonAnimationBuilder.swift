//
//  SkeletonAnimationBuilder.swift
//  popup
//
//  Created by Ivan Glushko on 01.11.2022.
//

import Foundation

import UIKit

typealias SkeletonLayerAnimation = (CALayer) -> CAAnimation

enum SkeletonAnimationType {
    case pulse
    case waterfall(index: CGFloat, delay: Double)
    case slidingGradient(direction: SkeletonGradientDirection)
}

class SkeletonAnimationBuilder {

    init() {}

    func makeSlidingAnimation(
        withDirection direction: SkeletonGradientDirection,
        duration: Double = 1.5,
        autoreverses: Bool = true
    ) -> SkeletonLayerAnimation {
        { _ in
            let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
            startPointAnim.fromValue = direction.startPoint.from
            startPointAnim.toValue = direction.startPoint.to

            let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
            endPointAnim.fromValue = direction.endPoint.from
            endPointAnim.toValue = direction.endPoint.to

            let animGroup = CAAnimationGroup()
            animGroup.animations = [startPointAnim, endPointAnim]
            animGroup.duration = duration
            animGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animGroup.repeatCount = .infinity
            animGroup.autoreverses = autoreverses
            animGroup.isRemovedOnCompletion = false

            return animGroup
        }
    }

    func makePulseAnimation(
        color: UIColor.Dynamic,
        duration: Double = 1,
        delay: Double = 0,
        speed: Float = 1,
        autoreverses: Bool = true
    ) -> SkeletonLayerAnimation {
        { layer in
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.fromValue = layer.opacity
            animation.toValue = 0.7
            animation.autoreverses = autoreverses
            animation.repeatCount = .infinity
            animation.duration = duration
            animation.timeOffset = -delay
            animation.speed = speed
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.isRemovedOnCompletion = false
            return animation
        }
    }

    func makeWaterfallAnimation(
        viewCurrentAlpha: CGFloat,
        duration: Double = 1.5,
        delay: Double = 0,
        speed: Float = 1,
        autoreverses: Bool = true
    ) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = viewCurrentAlpha
        animation.toValue = 0.4 as CGFloat
        animation.autoreverses = autoreverses
        animation.repeatCount = .infinity
        animation.duration = duration
        animation.timeOffset = -delay
        animation.speed = speed
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.isRemovedOnCompletion = false
        return animation
    }
}

typealias GradientAnimationPoint = (from: CGPoint, to: CGPoint)
