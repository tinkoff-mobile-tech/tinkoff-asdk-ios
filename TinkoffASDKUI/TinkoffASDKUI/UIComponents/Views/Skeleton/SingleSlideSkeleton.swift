//
//  SingleSlideSkeleton.swift
//  popup
//
//  Created by Ivan Glushko on 09.11.2022.
//

import UIKit

class SingleSlideSkeleton {

    private let gradientView: UIView
    private let gradientLayer: CAGradientLayer
    private let skeletonsContainerView: UIView

    init(
        _ initializer: @escaping (
            _ gradientView: UIView,
            _ skeletonsContainerView: UIView
        ) -> Void
    ) {
        let views = Self.createGradientViews()
        gradientView = views.gradientView
        gradientLayer = views.gradientLayer
        skeletonsContainerView = views.skeletonsContainerView
        initializer(gradientView, skeletonsContainerView)
        assert(
            gradientView.superview != nil,
            "Make sure to add gradientView to superview"
        )

        assert(
            !skeletonsContainerView.subviews.filter { $0 is SkeletonView }.isEmpty,
            "Place some skeletonViews onto skeletonsContainerView"
        )
    }

    func startAnimation(
        color: UIColor.Dynamic,
        direction: SkeletonGradientDirection
    ) {
        stopAnimation()
        startGradientAnimation(
            gradientLayer: gradientLayer,
            color: color,
            direction: direction
        )
    }

    func stopAnimation() {
        gradientLayer.removeAllAnimations()
    }

    /// Setup for gradientAnimation
    /// - Returns:
    /// - gradientView: UView - place that view into your view hirearchy
    /// - skeletonsContainerView: UIView - is already added to gradientView and constrained to gradientView
    private static func createGradientViews() -> (
        gradientView: UIView,
        gradientLayer: CAGradientLayer,
        skeletonsContainerView: UIView
    ) {
        let gradientView = DeinitView()
        gradientView.clipsToBounds = true
        let secondGradientView = DeinitView()
        let gradientLayer = CAGradientLayer()
        let skeletonsContainerView = UIView()
        gradientView.addSubview(skeletonsContainerView)
        gradientView.addSubview(secondGradientView)
        secondGradientView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = gradientView.bounds
        var observer: NSKeyValueObservation? = gradientView.observe(
            \.center,
            changeHandler: { view, _ in
                gradientLayer.frame = view.bounds
                skeletonsContainerView.frame = view.bounds
            }
        )

        gradientView.onDeinit = {
            observer = withExtendedLifetime(observer) { nil }
        }

        return (gradientView, gradientLayer, skeletonsContainerView)
    }

    private func startGradientAnimation(
        gradientLayer: CAGradientLayer,
        color: UIColor.Dynamic,
        direction: SkeletonGradientDirection
    ) {
        gradientLayer.mask = skeletonsContainerView.layer
        gradientLayer.locations = [0.25, 0.5, 0.75]
        gradientLayer.startPoint = direction.endPoint.from
        gradientLayer.endPoint = direction.startPoint.to

        let mainColor = color.color
        gradientLayer.colors = [
            mainColor.cgColor,
            mainColor.withAlphaComponent(0.80).cgColor,
            mainColor.cgColor,
        ]

        gradientLayer.add(buildAnimation(), forKey: nil)
    }

    private func buildAnimation() -> CABasicAnimation {
        let gradientAnimation = CABasicAnimation(
            keyPath: #keyPath(CAGradientLayer.locations)
        )
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.autoreverses = true
        gradientAnimation.duration = 1.5
        gradientAnimation.fromValue = [0.0, 0.25, 0.5]
        gradientAnimation.toValue = [0.5, 0.75, 1.0]
        return gradientAnimation
    }
}

extension SingleSlideSkeleton {

    private class DeinitView: UIView {
        var onDeinit = {}
        deinit { onDeinit() }
    }
}
