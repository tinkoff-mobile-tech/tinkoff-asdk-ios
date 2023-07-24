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

    override var navigationController: UINavigationController? {
        get { return underlyingNavigationController ?? super.navigationController }
        set(value) { underlyingNavigationController = value }
    }

    var underlyingNavigationController: UINavigationController?

    override var presentingViewController: UIViewController? {
        get { return underlyingPresentingViewController }
        set(value) { underlyingPresentingViewController = value }
    }

    var underlyingPresentingViewController: UIViewController?

    override var presentedViewController: UIViewController? {
        get { return underlyingPresentedViewController }
        set(value) { underlyingPresentedViewController = value }
    }

    var underlyingPresentedViewController: UIViewController?

    override var transitionCoordinator: UIViewControllerTransitionCoordinator? {
        get { return underlyingTransitionCoordinator }
        set(value) { underlyingTransitionCoordinator = value }
    }

    var underlyingTransitionCoordinator: UIViewControllerTransitionCoordinator?

    // MARK: - present

    typealias PresentArguments = (viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)

    var presentCallsCount = 0
    var presentReceivedArguments: PresentArguments?
    var presentReceivedInvocations: [PresentArguments?] = []
    var presentCompletionShouldExecute = false

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentCallsCount += 1
        let arguments = (viewControllerToPresent, animated, completion)
        presentReceivedArguments = arguments
        presentReceivedInvocations.append(arguments)
        if presentCompletionShouldExecute {
            completion?()
        }
    }

    // MARK: - dismiss

    typealias DismissArguments = (animated: Bool, completion: (() -> Void)?)

    var dismissCallsCount = 0
    var dismissReceivedArguments: DismissArguments?
    var dismissReceivedInvocations: [DismissArguments?] = []
    var dismissCompletionShouldExecute = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallsCount += 1
        let arguments = (flag, completion)
        dismissReceivedArguments = arguments
        dismissReceivedInvocations.append(arguments)
        if dismissCompletionShouldExecute {
            completion?()
        }
    }
}
