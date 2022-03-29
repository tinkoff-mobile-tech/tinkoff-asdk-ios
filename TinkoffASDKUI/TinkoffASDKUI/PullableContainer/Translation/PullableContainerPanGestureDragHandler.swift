//
//
//  PullableContainerPanGestureDragHandler.swift
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

final class PullableContainerPanGestureDragHandler: PullableContainerDragHandler {
    private weak var dragController: PullableContainerDragController?
    private let panGestureRecognizer: UIPanGestureRecognizer

    init(dragController: PullableContainerDragController?,
         panGestureRecognizer: UIPanGestureRecognizer) {
        self.dragController = dragController
        self.panGestureRecognizer = panGestureRecognizer
        setup()
    }

    func cancel() {
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
    }
}

private extension PullableContainerPanGestureDragHandler {
    func setup() {
        panGestureRecognizer.addTarget(self, action: #selector(panGestureAction(_:)))
    }

    @objc func panGestureAction(_ recognizer: UIPanGestureRecognizer) {
        let yTranslation = panGestureRecognizer.translation(in: panGestureRecognizer.view).y
        switch recognizer.state {
        case .changed:
            dragController?.didDragWith(offset: yTranslation)
        case .ended:
            let yVelocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view).y
            dragController?.didEndDragging(offset: yTranslation, velocity: yVelocity)
        case .cancelled, .failed:
            dragController?.didEndDragging(offset: 0, velocity: 0)
        default:
            break
        }
    }
}
