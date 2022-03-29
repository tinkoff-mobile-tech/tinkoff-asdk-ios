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
    private weak var dragController: PullableContainerDragController?
    private let scrollView: UIScrollView
    
    private var isMoving = false
    private var translatingBeginOffset: CGFloat = 0
    
    init(dragController: PullableContainerDragController?,
         scrollView: UIScrollView) {
        self.dragController = dragController
        self.scrollView = scrollView
        super.init()
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
        let yTranslation = recognizer.translation(in: scrollView).y
        let yVelocity = recognizer.velocity(in: scrollView).y
        
        let isScrollDown = yVelocity > 0
        let isOnTop = scrollView.contentOffset.y <= 0
        let isMovingDownAction = (isScrollDown && isOnTop)
        
        switch recognizer.state {
        case .possible:
            scrollView.contentOffset = .zero
        case .began:
            if isMovingDownAction {
                isMoving = true
                scrollView.setContentOffset(.zero, animated: false)
            }
        case .changed:
            if isMovingDownAction {
                if !isMoving {
                    isMoving = true
                    translatingBeginOffset = yTranslation
                }
                let movingOffset = yTranslation - translatingBeginOffset
                dragController?.didDragWith(offset: movingOffset)
                scrollView.contentOffset = .zero
            } else {
                if isMoving {
                    scrollView.setContentOffset(.zero, animated: false)
                    let movingOffset = yTranslation - translatingBeginOffset
                    dragController?.didDragWith(offset: movingOffset)
                    isMoving = !(movingOffset < 0)
                }
            }
        case .cancelled, .ended:
            if isMoving {
                dragController?.didEndDragging(offset: yTranslation, velocity: yVelocity)
            }
        default:
            break
        }
    }
}
