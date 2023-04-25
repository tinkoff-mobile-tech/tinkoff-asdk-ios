//
//  UIViewControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import UIKit

final class UIViewControllerMock: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var invokedNavigationControllerGetter = false
    public var invokedNavigationControllerGetterCount = 0
    public var stubbedNavigationController: UINavigationController?
    override public var navigationController: UINavigationController? {
        invokedNavigationControllerGetter = true
        invokedNavigationControllerGetterCount += 1
        return stubbedNavigationController ?? super.navigationController
    }

    public var invokedPresentAnimated = false
    public var invokedPresentAnimatedCount = 0
    public var invokedPresentAnimatedParameters: (viewControllerToPresent: UIViewController, animated: Bool)?
    public var invokedPresentAnimatedParametersList = [(viewControllerToPresent: UIViewController, animated: Bool)]()
    public var shouldInvokePresentAnimatedCompletion = false

    override public func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        invokedPresentAnimated = true
        invokedPresentAnimatedCount += 1
        invokedPresentAnimatedParameters = (viewControllerToPresent, animated)
        invokedPresentAnimatedParametersList.append((viewControllerToPresent, animated))
        if shouldInvokePresentAnimatedCompletion {
            completion?()
        }
    }

    public var invokedPresentingViewControllerGetter = false
    public var invokedPresentingViewControllerGetterCount = 0
    public var stubbedPresentingViewController: UIViewController!

    override public var presentingViewController: UIViewController? {
        invokedPresentingViewControllerGetter = true
        invokedPresentingViewControllerGetterCount += 1
        return stubbedPresentingViewController
    }

    public var invokedPresentedViewControllerGetter = false
    public var invokedPresentedViewControllerGetterCount = 0
    public var stubbedPresentedViewController: UIViewController!

    override public var presentedViewController: UIViewController? {
        invokedPresentedViewControllerGetter = true
        invokedPresentedViewControllerGetterCount += 1
        return stubbedPresentedViewController
    }

    public var invokedDismissAnimated = false
    public var invokedDismissAnimatedCount = 0
    public var invokedDismissAnimatedParameters: (flag: Bool, Void)?
    public var invokedDismissAnimatedParametersList = [(flag: Bool, Void)?]()
    public var shouldInvokeDismissAnimatedCompletion = false

    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        invokedDismissAnimated = true
        invokedDismissAnimatedCount += 1
        invokedDismissAnimatedParameters = (flag, ())
        invokedDismissAnimatedParametersList.append((flag, ()))
        if shouldInvokeDismissAnimatedCompletion {
            completion?()
        }
    }

    public var invokedTransitionCoordinatorGetter = false
    public var invokedTransitionCoordinatorGetterCount = 0
    public var stubbedTransitionCoordinator: UIViewControllerTransitionCoordinator?

    override public var transitionCoordinator: UIViewControllerTransitionCoordinator? {
        invokedTransitionCoordinatorGetter = true
        invokedTransitionCoordinatorGetterCount += 1
        return stubbedTransitionCoordinator
    }
}
