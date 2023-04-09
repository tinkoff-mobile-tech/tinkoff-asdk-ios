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

    func dragControllerDidRequestNumberOfAnchors(_ dragController: PullableContainerDragController) -> Int

    func dragController(
        _ dragController: PullableContainerDragController,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat

    func dragController(_ dragController: PullableContainerDragController, shouldUseAnchorAt index: Int) -> Bool
}

final class PullableContainerDragController {
    struct Anchor {
        let index: Int
        let height: CGFloat
    }

    // MARK: Dependencies

    private weak var delegate: PullableContainerDragControllerDelegate?
    private let dragViewHeightConstraint: NSLayoutConstraint

    // MARK: State

    var insets: UIEdgeInsets = .zero
    private var currentAnchor = Anchor(index: .zero, height: .zero)

    // MARK: Init

    init(dragViewHeightConstraint: NSLayoutConstraint, delegate: PullableContainerDragControllerDelegate?) {
        self.dragViewHeightConstraint = dragViewHeightConstraint
        self.delegate = delegate
    }

    // MARK: PullableContainerDragController

    func setDefaultPositionWithContentHeight(_ contentHeight: CGFloat) {
        currentAnchor = Anchor(index: .zero, height: contentHeight + insets.bottom + insets.top)
        dragViewHeightConstraint.constant = currentAnchor.height
    }

    func didDragWith(offset: CGFloat) {
        if offset <= 0 {
            performUpdatesForNegative(dragOffset: offset)
        } else {
            performUpdatesForPositive(dragOffset: offset)
        }
    }

    func didEndDragging(offset: CGFloat, velocity: CGFloat) {
        let dragProportion = abs(offset / currentAnchor.height)
        let isMovingChange = dragProportion >= .dismissDragProportionTreshold || velocity > .dismissVelocityTreshold

        if isMovingChange, offset < 0 {
            currentAnchor = nearestUpperAnchor(for: currentAnchor, consideringOffset: offset) ?? currentAnchor
            dragViewHeightConstraint.updateConstantIfNeeded(currentAnchor.height)
            delegate?.dragControllerDidEndDragging(self)
        } else if isMovingChange, let nearestLowerAnchor = nearestLowerAnchor(for: currentAnchor, consideringOffset: offset) {
            currentAnchor = nearestLowerAnchor
            dragViewHeightConstraint.updateConstantIfNeeded(currentAnchor.height)
            delegate?.dragControllerDidEndDragging(self)
        } else if isMovingChange, shouldDismissOnDownDragging() {
            delegate?.dragControllerDidCloseContainer(self)
        } else {
            dragViewHeightConstraint.updateConstantIfNeeded(currentAnchor.height)
            delegate?.dragControllerDidEndDragging(self)
        }
    }

    // MARK: Helpers

    private func performUpdatesForNegative(dragOffset: CGFloat) {
        assert(dragOffset <= 0)
        let dragViewHeight: CGFloat

        if let farthestAnchor = farthestUpperAnchor(for: currentAnchor) {
            let difference = currentAnchor.height - farthestAnchor.height
            let normalizedOffset = difference + (dragOffset - difference) * .dragOffsetCoefficient
            let limitedOffset = difference - .maximumDragOffset

            let resultOffset = (currentAnchor.height - dragOffset) > farthestAnchor.height
                ? max(normalizedOffset, limitedOffset)
                : dragOffset

            dragViewHeight = currentAnchor.height - resultOffset
        } else {
            let normalizedOffset = max(-.maximumDragOffset, dragOffset * .dragOffsetCoefficient)
            dragViewHeight = currentAnchor.height - normalizedOffset
        }

        dragViewHeightConstraint.updateConstantIfNeeded(dragViewHeight)
    }

    private func performUpdatesForPositive(dragOffset: CGFloat) {
        assert(dragOffset > 0)
        let dragViewHeight: CGFloat

        if shouldDismissOnDownDragging() {
            dragViewHeight = currentAnchor.height - dragOffset
        } else if let farthestAnchor = farthestLowerAnchor(for: currentAnchor) {
            let difference = currentAnchor.height - farthestAnchor.height
            let normalizedOffset = difference + (dragOffset - difference) * .dragOffsetCoefficient
            let limitedOffset = difference - .maximumDragOffset

            let resultOffset = (currentAnchor.height - dragOffset) < farthestAnchor.height
                ? max(normalizedOffset, limitedOffset)
                : dragOffset

            dragViewHeight = currentAnchor.height - resultOffset
        } else {
            let resultOffset = min(.maximumDragOffset, dragOffset * .dragOffsetCoefficient)
            dragViewHeight = max(currentAnchor.height - resultOffset, currentAnchor.height - .maximumDragOffset)
        }

        dragViewHeightConstraint.updateConstantIfNeeded(dragViewHeight)
    }

    private func availableSpace() -> CGFloat {
        guard let delegate = delegate else {
            return currentAnchor.height
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

    private func farthestUpperAnchor(for currentAnchor: Anchor) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height > currentAnchor.height }
            .max { $0.height < $1.height }
    }

    private func nearestUpperAnchor(for currentAnchor: Anchor, consideringOffset offset: CGFloat) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height > currentAnchor.height - offset }
            .min { $0.height < $1.height }
    }

    private func farthestLowerAnchor(for currentAnchor: Anchor) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height < currentAnchor.height }
            .min { $0.height < $1.height }
    }

    private func nearestLowerAnchor(for currentAnchor: Anchor, consideringOffset offset: CGFloat) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height < currentAnchor.height - offset }
            .max { $0.height < $1.height }
    }

    private func allReachableAnchors(without currentAnchor: Anchor) -> [Anchor] {
        guard let delegate = delegate else { return [] }

        return (0 ..< delegate.dragControllerDidRequestNumberOfAnchors(self))
            .enumerated()
            .filter { $0.offset != currentAnchor.index && delegate.dragController(self, shouldUseAnchorAt: $0.offset) }
            .compactMap { anchor(withIndex: $0.offset) }
    }

    private func anchor(withIndex index: Int) -> Anchor? {
        guard let delegate = delegate else { return nil }

        return Anchor(
            index: index,
            height: delegate.dragController(self, didRequestHeightForAnchorAt: index, availableSpace: availableSpace())
        )
    }
}

// MARK: - Constants

private extension Bool {
    static let defaultShouldDismissOnDownDragging = true
}

private extension CGFloat {
    static let dismissVelocityTreshold: CGFloat = 1500
    static let dismissDragProportionTreshold: CGFloat = 1 / 4
    static let maximumDragOffset: CGFloat = 20
    static let dragOffsetCoefficient: CGFloat = 1 / 2
}

// MARK: - Helpers

private extension NSLayoutConstraint {
    func updateConstantIfNeeded(_ constant: CGFloat) {
        guard self.constant != constant else { return }
        self.constant = constant
    }
}
