//
//
//  PullableContainerDragController.swift
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

protocol PullableContainerDragControllerDelegate: AnyObject {
    func dragControllerDidRequestMaxContentHeight(_ controller: PullableContainerDragController) -> CGFloat
    func dragControllerDidEndDragging(_ controller: PullableContainerDragController)
    func dragControllerDidCloseContainer(_ controller: PullableContainerDragController)
    func dragControllerShouldDismissOnDownDragging(_ controller: PullableContainerDragController) -> Bool
}

final class PullableContainerDragController {
    weak var delegate: PullableContainerDragControllerDelegate?
    var insets: UIEdgeInsets = .zero
    private let dragViewHeightConstraint: NSLayoutConstraint
    private var dragViewHeight: CGFloat = 0

    // MARK: Init

    init(dragViewHeightConstraint: NSLayoutConstraint) {
        self.dragViewHeightConstraint = dragViewHeightConstraint
    }

    // MARK: Internal

    func setDefaultPositionWithContentHeight(_ contentHeight: CGFloat) {
        dragViewHeight = contentHeight + insets.bottom + insets.top
        dragViewHeightConstraint.constant = dragViewHeight
    }

    func didDragWith(offset: CGFloat) {
        dragViewHeightConstraint.constant = calculateDragViewHeight(offset: offset)
    }

    func didEndDragging(
        offset: CGFloat,
        velocity: CGFloat
    ) {
        let dragProportion = offset / dragViewHeight
        let isDismissingDrag = dragProportion >= .dismissDragProportionTreshold || velocity > .dismissVelocityTreshold
        let isDismissionAllowed = delegate?.dragControllerShouldDismissOnDownDragging(self) ?? true

        if isDismissingDrag, isDismissionAllowed {
            delegate?.dragControllerDidCloseContainer(self)
        } else {
            dragViewHeightConstraint.constant = dragViewHeight
            delegate?.dragControllerDidEndDragging(self)
        }
    }

    // MARK: Helpers

    private func calculateDragViewHeight(offset: CGFloat) -> CGFloat {
        offset < 0
            ? calculateDragViewHeightForTopDirectionDragging(offset: offset)
            : calculateDragViewHeightForBottomDirectionDragging(offset: offset)
    }

    private func calculateDragViewHeightForTopDirectionDragging(offset: CGFloat) -> CGFloat {
        assert(offset <= 0)
        let resultOffset = max(-.maximumDragOffset, offset / 2)
        let resultHeight = min(maximumDragViewHeight(), dragViewHeight - resultOffset)
        return resultHeight
    }

    private func calculateDragViewHeightForBottomDirectionDragging(offset: CGFloat) -> CGFloat {
        assert(offset >= 0)

        if shouldDismissOnDownDragging() {
            return dragViewHeight - offset
        } else {
            let resultOffset = min(.maximumDragOffset, offset / 2)
            return max(dragViewHeight - resultOffset, dragViewHeight - .maximumDragOffset)
        }
    }

    private func maximumDragViewHeight() -> CGFloat {
        guard let delegate = delegate else {
            return dragViewHeight
        }

        let maximumHeight = delegate.dragControllerDidRequestMaxContentHeight(self)
            + insets.bottom
            + insets.top

        return maximumHeight
    }

    private func shouldDismissOnDownDragging() -> Bool {
        guard let delegate = delegate else {
            return .defaultShouldDismissOnDownDragging
        }

        return delegate.dragControllerShouldDismissOnDownDragging(self)
    }
}

// MARK: - Constants

private extension Bool {
    static let defaultShouldDismissOnDownDragging = true
}

private extension CGFloat {
    static let dismissVelocityTreshold: CGFloat = 1500
    static let dismissDragProportionTreshold: CGFloat = 1 / 4
    static let maximumDragOffset: CGFloat = 50
}
