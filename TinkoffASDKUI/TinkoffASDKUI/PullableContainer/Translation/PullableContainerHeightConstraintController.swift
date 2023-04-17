//
//
//  PullableContainerHeightConstraintController.swift
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

protocol PullableContainerHeightConstraintControllerDelegate: AnyObject {
    func heightConstraintControllerDidRequestAvailableSpace(_ controller: PullableContainerHeightConstraintController) -> CGFloat
    func heightConstraintControllerDidEndDragging(_ controller: PullableContainerHeightConstraintController)
    func heightConstraintControllerDidCloseContainer(_ controller: PullableContainerHeightConstraintController)
    func heightConstraintControllerShouldDismissOnDownDragging(_ controller: PullableContainerHeightConstraintController) -> Bool
    func heightConstraintControllerDidRequestCurrentAnchorIndex(_ controller: PullableContainerHeightConstraintController) -> Int
    func heightConstraintControllerDidRequestNumberOfAnchors(_ controller: PullableContainerHeightConstraintController) -> Int
    func heightConstraintController(_ controller: PullableContainerHeightConstraintController, didChange currentAnchorIndex: Int)
    func heightConstraintController(_ controller: PullableContainerHeightConstraintController, shouldUseAnchorAt index: Int) -> Bool
    func heightConstraintController(_ controller: PullableContainerHeightConstraintController, didDragWithOffset offset: CGFloat)

    func heightConstraintController(
        _ controller: PullableContainerHeightConstraintController,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat
}

final class PullableContainerHeightConstraintController {
    // MARK: Internal Types

    struct Anchor {
        let index: Int
        let height: CGFloat
    }

    // MARK: Dependencies

    private weak var delegate: PullableContainerHeightConstraintControllerDelegate?
    private let dragViewHeightConstraint: NSLayoutConstraint

    // MARK: State

    var insets: UIEdgeInsets = .zero

    // MARK: Init

    init(dragViewHeightConstraint: NSLayoutConstraint, delegate: PullableContainerHeightConstraintControllerDelegate?) {
        self.dragViewHeightConstraint = dragViewHeightConstraint
        self.delegate = delegate
    }

    // MARK: PullableContainerHeightConstraintController

    func updateHeight() {
        guard let currentAnchor = currentAnchor() else { return }
        updateConstraintIfNeeded(dragViewHeight: currentAnchor.height)
    }

    func didDragWith(offset: CGFloat) {
        if offset <= 0 {
            performUpdatesForNegative(dragOffset: offset)
        } else {
            performUpdatesForPositive(dragOffset: offset)
        }
    }

    func didEndDragging(offset: CGFloat, velocity: CGFloat) {
        guard let delegate = delegate, let currentAnchor = currentAnchor() else { return }

        let dragProportion = abs(offset / currentAnchor.height)
        let isMovingChange = dragProportion >= .movingDragProportionTreshold || velocity > .movingVelocityTreshold

        if isMovingChange, offset < 0 {
            let newAnchor = nearestUpperAnchor(for: currentAnchor, consideringOffset: offset) ?? currentAnchor
            updateConstraintIfNeeded(dragViewHeight: newAnchor.height)
            delegate.heightConstraintControllerDidEndDragging(self)
            delegate.heightConstraintController(self, didChange: newAnchor.index)
        } else if isMovingChange, let nearestLowerAnchor = nearestLowerAnchor(for: currentAnchor, consideringOffset: offset) {
            updateConstraintIfNeeded(dragViewHeight: nearestLowerAnchor.height)
            delegate.heightConstraintControllerDidEndDragging(self)
            delegate.heightConstraintController(self, didChange: nearestLowerAnchor.index)
        } else if isMovingChange, shouldDismissOnDownDragging() {
            delegate.heightConstraintControllerDidCloseContainer(self)
        } else {
            updateConstraintIfNeeded(dragViewHeight: currentAnchor.height)
            delegate.heightConstraintControllerDidEndDragging(self)
        }
    }

    // MARK: Helpers

    private func performUpdatesForNegative(dragOffset: CGFloat) {
        assert(dragOffset <= 0)
        guard let currentAnchor = currentAnchor() else { return }

        let resultOffset: CGFloat

        if let farthestAnchor = farthestUpperAnchor(for: currentAnchor) {
            let difference = currentAnchor.height - farthestAnchor.height
            let normalizedOffset = difference + (dragOffset - difference) * .dragOffsetCoefficient
            let limitedOffset = difference - .maximumDragOffset

            resultOffset = (currentAnchor.height - dragOffset) > farthestAnchor.height
                ? max(normalizedOffset, limitedOffset)
                : dragOffset

        } else {
            resultOffset = max(-.maximumDragOffset, dragOffset * .dragOffsetCoefficient)
        }

        updateConstraintIfNeeded(dragViewHeight: currentAnchor.height - resultOffset)

        delegate?.heightConstraintController(self, didDragWithOffset: resultOffset)
    }

    private func performUpdatesForPositive(dragOffset: CGFloat) {
        assert(dragOffset > 0)
        guard let currentAnchor = currentAnchor() else { return }

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

        updateConstraintIfNeeded(dragViewHeight: dragViewHeight)

        delegate?.heightConstraintController(self, didDragWithOffset: currentAnchor.height - dragViewHeight)
    }

    private func availableSpace() -> CGFloat {
        guard let delegate = delegate else {
            return .zero
        }

        return delegate.heightConstraintControllerDidRequestAvailableSpace(self)
    }

    private func shouldDismissOnDownDragging() -> Bool {
        delegate?.heightConstraintControllerShouldDismissOnDownDragging(self) ?? true
    }

    private func farthestUpperAnchor(for currentAnchor: Anchor) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height > currentAnchor.height }
            .max { $0.height < $1.height }
    }

    private func nearestUpperAnchor(for currentAnchor: Anchor, consideringOffset offset: CGFloat) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height > currentAnchor.height }
            .min { $0.height < $1.height }
    }

    private func farthestLowerAnchor(for currentAnchor: Anchor) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height < currentAnchor.height }
            .min { $0.height < $1.height }
    }

    private func nearestLowerAnchor(for currentAnchor: Anchor, consideringOffset offset: CGFloat) -> Anchor? {
        allReachableAnchors(without: currentAnchor)
            .filter { $0.height < currentAnchor.height }
            .max { $0.height < $1.height }
    }

    private func allReachableAnchors(without currentAnchor: Anchor) -> [Anchor] {
        guard let delegate = delegate else { return [] }

        return (0 ..< delegate.heightConstraintControllerDidRequestNumberOfAnchors(self))
            .enumerated()
            .filter { $0.offset != currentAnchor.index && delegate.heightConstraintController(self, shouldUseAnchorAt: $0.offset) }
            .compactMap { anchor(withIndex: $0.offset) }
    }

    private func currentAnchor() -> Anchor? {
        guard let delegate = delegate else { return nil }

        let currentAnchorIndex = delegate.heightConstraintControllerDidRequestCurrentAnchorIndex(self)
        return anchor(withIndex: currentAnchorIndex)
    }

    private func anchor(withIndex index: Int) -> Anchor? {
        guard let delegate = delegate else { return nil }

        return Anchor(
            index: index,
            height: delegate.heightConstraintController(self, didRequestHeightForAnchorAt: index, availableSpace: availableSpace())
        )
    }

    private func updateConstraintIfNeeded(dragViewHeight: CGFloat) {
        let constant = dragViewHeight + insets.vertical
        guard dragViewHeightConstraint.constant != constant else { return }
        dragViewHeightConstraint.constant = constant
    }
}

// MARK: - Constants

private extension CGFloat {
    static let movingVelocityTreshold: CGFloat = 1500
    static let movingDragProportionTreshold: CGFloat = 1 / 4
    static let maximumDragOffset: CGFloat = 20
    static let dragOffsetCoefficient: CGFloat = 1 / 2
}
