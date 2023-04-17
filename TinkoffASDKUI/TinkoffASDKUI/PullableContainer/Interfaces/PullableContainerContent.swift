//
//
//  PullableContainerContent.swift
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

protocol PullableContainerContent: AnyObject {
    func pullableContainerDidRequestContentView(_ contentDelegate: PullableContainerСontentDelegate) -> UIView
    func pullableContainerDidRequestScrollView(_ contentDelegate: PullableContainerСontentDelegate) -> UIScrollView?
    func pullableContainerDidRequestNumberOfAnchors(_ contentDelegate: PullableContainerСontentDelegate) -> Int
    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: PullableContainerСontentDelegate) -> Int

    func pullableContainer(
        _ contentDelegate: PullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat

    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didDragWithOffset offset: CGFloat)
    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didChange currentAnchorIndex: Int)
    func pullabeContainer(_ contentDelegate: PullableContainerСontentDelegate, canReachAnchorAt index: Int) -> Bool
    func pullableContainerWillBeClosed(_ contentDelegate: PullableContainerСontentDelegate)
    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate)
    func pullableContainerShouldDismissOnDownDragging(_ contentDelegate: PullableContainerСontentDelegate) -> Bool
    func pullableContainerShouldDismissOnDimmingViewTap(_ contentDelegate: PullableContainerСontentDelegate) -> Bool
}

// MARK: - PullableContainerContent + Default Implementation

extension PullableContainerContent {
    func pullableContainerDidRequestScrollView(_ contentDelegate: PullableContainerСontentDelegate) -> UIScrollView? { nil }
    func pullableContainerDidRequestNumberOfAnchors(_ contentDelegate: PullableContainerСontentDelegate) -> Int { 1 }
    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: PullableContainerСontentDelegate) -> Int { .zero }
    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didDragWithOffset offset: CGFloat) {}
    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didChange currentAnchorIndex: Int) {}
    func pullabeContainer(_ contentDelegate: PullableContainerСontentDelegate, canReachAnchorAt index: Int) -> Bool { true }
    func pullableContainerWillBeClosed(_ contentDelegate: PullableContainerСontentDelegate) {}
    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate) {}
    func pullableContainerShouldDismissOnDownDragging(_ contentDelegate: PullableContainerСontentDelegate) -> Bool { true }
    func pullableContainerShouldDismissOnDimmingViewTap(_ contentDelegate: PullableContainerСontentDelegate) -> Bool { true }
}

extension PullableContainerContent where Self: UIViewController {
    func pullableContainerDidRequestContentView(_ contentDelegate: PullableContainerСontentDelegate) -> UIView { view }
}
