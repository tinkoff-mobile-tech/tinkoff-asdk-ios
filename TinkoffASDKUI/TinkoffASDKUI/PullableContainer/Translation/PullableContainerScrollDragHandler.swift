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

final class PullableContainerScrollDragHandler: PullableContainerDragHandler {
    private weak var heightConstraintController: PullableContainerHeightConstraintController?
    private let scrollView: UIScrollView

    private var isMoving = false
    private var lastScrollTranslation: CGFloat = .zero
    private var translatingBeginOffset: CGFloat = .zero

    init(
        heightConstraintController: PullableContainerHeightConstraintController?,
        scrollView: UIScrollView
    ) {
        self.heightConstraintController = heightConstraintController
        self.scrollView = scrollView
        setup()
    }

    func cancel() {
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = true
    }
}

private extension PullableContainerScrollDragHandler {
    func setup() {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(scrollPanGestureAction(_:)))
    }

    @objc func scrollPanGestureAction(_ recognizer: UIPanGestureRecognizer) {
        guard let controller = heightConstraintController else { return }

        let yTranslation = recognizer.translation(in: scrollView).y
        let yVelocity = recognizer.velocity(in: scrollView).y

        let lastScrollTranslation = self.lastScrollTranslation
        self.lastScrollTranslation = yTranslation

        let isScrollsDown = (lastScrollTranslation - yTranslation) < 0
        let isScrollsUp = !isScrollsDown

        let isOnTopPosition = scrollView.contentOffset.y - abs(yTranslation) <= 0
        let isMovingDownAction = isScrollsDown && isOnTopPosition
        let isMovingUpAction = isScrollsUp && isOnTopPosition && !controller.maxHeightIsReached

        switch recognizer.state {
        case .changed:
            if isMovingDownAction || isMovingUpAction {
                if !isMoving {
                    isMoving = true
                    translatingBeginOffset = yTranslation
                }
                let movingOffset = yTranslation - translatingBeginOffset
                controller.didDragWith(offset: movingOffset)

                scrollView.setContentOffset(.zero, animated: false)
            } else {
                if isMoving {
                    scrollView.setContentOffset(.zero, animated: false)
                    let movingOffset = yTranslation - translatingBeginOffset
                    controller.didDragWith(offset: movingOffset)
                    isMoving = movingOffset >= 0
                }
            }
        case .cancelled, .ended:
            if isMoving {
                controller.didEndDragging(offset: yTranslation, velocity: yVelocity)
                scrollView.setContentOffset(.zero, animated: false)
            }

            self.lastScrollTranslation = .zero
            translatingBeginOffset = .zero
            isMoving = false
        default:
            break
        }
    }
}
