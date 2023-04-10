//
//
//  PullableContainerScrollDragHandler.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

final class PullableContainerScrollDragHandler: NSObject, PullableContainerDragHandler {
    // MARK: Dependencies

    private weak var dragController: PullableContainerDragController?
    private let scrollView: UIScrollView
    private let scrollViewDelegateProxy = PullableScrollViewDelegateProxy()

    // MARK: State

    private var pullableTranslation: CGFloat = .zero
    private var scrollViewTranslation: CGFloat = .zero
    private var lastContentOffsetWhileScrolling: CGPoint = .zero

    private var isMoving = false
    private var translatingBeginOffset: CGFloat = 0

    init(
        dragController: PullableContainerDragController?,
        scrollView: UIScrollView
    ) {
        self.dragController = dragController
        self.scrollView = scrollView
        super.init()
        scrollViewDelegateProxy.forward(to: self, delegateInvocationsFrom: scrollView)
    }

    func cancel() {
        scrollViewDelegateProxy.cancelForwarding()
    }
}

// MARK: - PullableScrollViewDelegate

extension PullableContainerScrollDragHandler: PullableScrollViewDelegate {
    func pullableScrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    func pullableScrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dragController = dragController else { return }

        let previousTranslation = scrollViewTranslation
        scrollViewTranslation = scrollView.panGestureRecognizer.translation(in: scrollView).y
    }

    func pullableScrollView(
        _ scrollView: UIScrollView,
        willEndDraggingwithVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {}
}

// MARK: - PullableContainerScrollDragHandler + Helpers

private extension PullableContainerScrollDragHandler {
    private func shouldDragOverlay(following scrollView: UIScrollView) -> Bool {
        guard let controller = dragController, scrollView.isTracking else { return false }

        let velocity = scrollView.panGestureRecognizer.velocity(in: nil).y
        let movesUp = velocity < 0

        switch controller.translationPosition {
        case .bottom:
            return !scrollView.isContentOriginInBounds && scrollView.scrollsUp
        case .top:
            return scrollView.isContentOriginInBounds && !movesUp
        case .inFlight:
            return scrollView.isContentOriginInBounds || scrollView.scrollsUp
        case .stationary:
            return false
        }
    }
}

// MARK: - UIScrollView + Helpers

private extension UIScrollView {
    var scrollsUp: Bool {
        return panGestureRecognizer.yDirection == .up
    }

    var isContentOriginInBounds: Bool {
        topOffsetInContent <= 0.0
    }

    var topOffsetInContent: CGFloat {
        contentOffset.y + adjustedContentInset.top
    }

    func scrollToTop() {
        contentOffset.y = -adjustedContentInset.top
    }
}

// MARK: - UIPanGestureRecognizer + Helpers

private extension UIPanGestureRecognizer {
    enum VerticalDirection {
        case up
        case down
        case none
    }

    var yDirection: VerticalDirection {
        let yVelocity = velocity(in: nil).y
        if yVelocity == 0 {
            return .none
        }
        if yVelocity < 0 {
            return .up
        }
        return .down
    }
}
