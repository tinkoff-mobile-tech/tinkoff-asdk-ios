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
    func pullableContainerDragControllerMaximumContentHeight(_ controller: PullableContainerDragController) -> CGFloat
    func pullableContainerDragControllerDidEndDragging(_ controller: PullableContainerDragController)
    func pullableContainerDragControllerDidCloseContainer(_ controller: PullableContainerDragController)
}

final class PullableContainerDragController {
    
    weak var delegate: PullableContainerDragControllerDelegate?
        
    private let dragViewHeightConstraint: NSLayoutConstraint
    
    private var dragViewHeight: CGFloat = 0
    
    var insets: UIEdgeInsets = .zero

    init(dragViewHeightConstraint: NSLayoutConstraint) {
        self.dragViewHeightConstraint = dragViewHeightConstraint
    }

    func setDefaultPositionWithContentHeight(_ contentHeight: CGFloat) {
        dragViewHeight = contentHeight + insets.bottom + insets.top
        dragViewHeightConstraint.constant = dragViewHeight
    }
    
    func didDragWith(offset: CGFloat) {
        dragViewHeightConstraint.constant = calculateDragViewHeight(offset: offset)
    }
    
    func didEndDragging(offset: CGFloat,
                        velocity: CGFloat) {
        let dragProportion = offset / dragViewHeight
        let isDismiss = dragProportion >= .dismissDragProportionTreshold || velocity > .dismissVelocityTreshold
        if isDismiss {
            delegate?.pullableContainerDragControllerDidCloseContainer(self)
        } else {
            dragViewHeightConstraint.constant = dragViewHeight
            delegate?.pullableContainerDragControllerDidEndDragging(self)
        }
    }
    
    private func calculateDragViewHeight(offset: CGFloat) -> CGFloat {
        let resultOffset = max(-.maximumDragOffset, (offset < 0 ? offset / 2 : offset))
        let resultHeight = min(maximumDragViewHeight(), dragViewHeight - resultOffset)
        return resultHeight
    }
    
    private func maximumDragViewHeight() -> CGFloat {
        guard let delegate = delegate else {
            return dragViewHeight
        }
        let maximumHeight = delegate.pullableContainerDragControllerMaximumContentHeight(self)
            - insets.bottom
            + insets.top
        return maximumHeight
    }
}

private extension CGFloat {
    static let dismissVelocityTreshold: CGFloat = 1500
    static let dismissDragProportionTreshold: CGFloat = 1/4
    static let maximumDragOffset: CGFloat = 50
}
