//
//
//  IPullableContainerContent.swift
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

protocol IPullableContainerContent: AnyObject {
    func pullableContainerDidRequestContentView(_ contentDelegate: IPullableContainerСontentDelegate) -> UIView
    func pullableContainerDidRequestScrollView(_ contentDelegate: IPullableContainerСontentDelegate) -> UIScrollView?
    func pullableContainerDidRequestNumberOfAnchors(_ contentDelegate: IPullableContainerСontentDelegate) -> Int
    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: IPullableContainerСontentDelegate) -> Int

    func pullableContainer(
        _ contentDelegate: IPullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat

    func pullableContainer(_ contentDelegate: IPullableContainerСontentDelegate, didDragWithOffset offset: CGFloat)
    func pullableContainer(_ contentDelegate: IPullableContainerСontentDelegate, didChange currentAnchorIndex: Int)
    func pullabeContainer(_ contentDelegate: IPullableContainerСontentDelegate, canReachAnchorAt index: Int) -> Bool
    func pullableContainerWillBeClosed(_ contentDelegate: IPullableContainerСontentDelegate)
    func pullableContainerWasClosed(_ contentDelegate: IPullableContainerСontentDelegate)
    func pullableContainerShouldDismissOnDownDragging(_ contentDelegate: IPullableContainerСontentDelegate) -> Bool
    func pullableContainerShouldDismissOnDimmingViewTap(_ contentDelegate: IPullableContainerСontentDelegate) -> Bool
}

// MARK: - IPullableContainerContent + Default Implementation

extension IPullableContainerContent {
    func pullableContainerDidRequestScrollView(_ contentDelegate: IPullableContainerСontentDelegate) -> UIScrollView? { nil }
    func pullableContainerDidRequestNumberOfAnchors(_ contentDelegate: IPullableContainerСontentDelegate) -> Int { 1 }
    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: IPullableContainerСontentDelegate) -> Int { .zero }
    func pullableContainer(_ contentDelegate: IPullableContainerСontentDelegate, didDragWithOffset offset: CGFloat) {}
    func pullableContainer(_ contentDelegate: IPullableContainerСontentDelegate, didChange currentAnchorIndex: Int) {}
    func pullabeContainer(_ contentDelegate: IPullableContainerСontentDelegate, canReachAnchorAt index: Int) -> Bool { true }
    func pullableContainerWillBeClosed(_ contentDelegate: IPullableContainerСontentDelegate) {}
    func pullableContainerWasClosed(_ contentDelegate: IPullableContainerСontentDelegate) {}
    func pullableContainerShouldDismissOnDownDragging(_ contentDelegate: IPullableContainerСontentDelegate) -> Bool { true }
    func pullableContainerShouldDismissOnDimmingViewTap(_ contentDelegate: IPullableContainerСontentDelegate) -> Bool { true }
}

extension IPullableContainerContent where Self: UIViewController {
    func pullableContainerDidRequestContentView(_ contentDelegate: IPullableContainerСontentDelegate) -> UIView { view }
}
