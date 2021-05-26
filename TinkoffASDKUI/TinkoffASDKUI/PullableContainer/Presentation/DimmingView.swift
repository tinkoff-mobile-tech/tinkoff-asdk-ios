//
//
//  DimmingView.swift
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

final class DimmingView: UIView {
    private let dismissedAlpha: CGFloat
    private let minimumAlpha: CGFloat
    private let maximumAlpha: CGFloat
    
    init(dismissedAlpha: CGFloat = 0.0,
         minimumAlpha: CGFloat = 0.4,
         maximumAlpha: CGFloat = 0.4) {
        self.dismissedAlpha = dismissedAlpha
        self.minimumAlpha = minimumAlpha
        self.maximumAlpha = maximumAlpha
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForPresentationTransition() {
        alpha = dismissedAlpha
    }
    
    func performPresentationTransition() {
        alpha = minimumAlpha
    }
    
    func prepareForDimissalTransition() { }
    
    func performDismissalTransition() {
        alpha = dismissedAlpha
    }
}

private extension DimmingView {
    func setup() {
        backgroundColor = .black
    }
}
