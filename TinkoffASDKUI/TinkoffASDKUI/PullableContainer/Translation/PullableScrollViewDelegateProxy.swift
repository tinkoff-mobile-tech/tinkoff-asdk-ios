//
//  PullableScrollViewDelegateProxy.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 09.04.2023.
//

import UIKit

protocol PullableScrollViewDelegate: AnyObject {
    func pullableScrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func pullableScrollViewDidScroll(_ scrollView: UIScrollView)

    func pullableScrollView(
        _ scrollView: UIScrollView,
        willEndDraggingwithVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    )
}

final class PullableScrollViewDelegateProxy: NSObject {
    // MARK: State

    private var scrollViewObservation: NSKeyValueObservation?
    private weak var originalDelegate: UIScrollViewDelegate?
    private weak var scrollView: UIScrollView?
    private weak var delegate: PullableScrollViewDelegate?

    // MARK: Life Cycle

    deinit {
        cancelForwarding()
    }

    // MARK: NSObject's Methods

    override func responds(to aSelector: Selector!) -> Bool {
        let originalDelegateRespondsToSelector = originalDelegate?.responds(to: aSelector) ?? false
        return super.responds(to: aSelector) || originalDelegateRespondsToSelector
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if originalDelegate?.responds(to: aSelector) == true {
            return originalDelegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }

    // MARK: PullableScrollViewDelegateProxy

    func forward(to delegate: PullableScrollViewDelegate, delegateInvocationsFrom scrollView: UIScrollView) {
        guard !(scrollView.delegate === self) else { return }

        cancelForwarding()

        self.delegate = delegate
        originalDelegate = scrollView.delegate
        self.scrollView = scrollView
        scrollView.delegate = self

        scrollViewObservation = scrollView.observe(\.delegate) { [weak self] scrollView, delegate in
            guard !(scrollView.delegate === self) else { return }

            if let proxy = scrollView.delegate as? PullableScrollViewDelegateProxy {
                proxy.originalDelegate = self?.originalDelegate
                self?.cancelForwarding(restoresDelegate: false)
            } else {
                self?.originalDelegate = scrollView.delegate
                self?.scrollView = scrollView
                scrollView.delegate = self
            }
        }
    }

    func cancelForwarding() {
        cancelForwarding(restoresDelegate: true)
    }

    // MARK: Helpers

    private func cancelForwarding(restoresDelegate: Bool) {
        scrollViewObservation?.invalidate()

        if restoresDelegate {
            scrollView?.delegate = originalDelegate
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PullableScrollViewDelegateProxy: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pullableScrollViewDidScroll(scrollView)
        originalDelegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        delegate?.pullableScrollView(
            scrollView,
            willEndDraggingwithVelocity: CGPoint(x: velocity.x * -1000, y: velocity.y * -1000),
            targetContentOffset: targetContentOffset
        )

        originalDelegate?.scrollViewWillEndDragging?(
            scrollView,
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.pullableScrollViewWillBeginDragging(scrollView)
        originalDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
}
