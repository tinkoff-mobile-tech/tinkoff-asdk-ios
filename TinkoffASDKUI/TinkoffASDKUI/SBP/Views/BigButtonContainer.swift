//
//
//  BigButtonContainer.swift
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

final class BigButtonContainer: UIView {

    private var button: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func placeButton(_ button: UIButton) {
        self.button?.removeFromSuperview()
        self.button = button

        addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false

        let buttonBottomConstraint = button.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -UIEdgeInsets.buttonInsets.bottom
        )
        buttonBottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(
                equalTo: topAnchor,
                constant: UIEdgeInsets.buttonInsets.top
            ),
            button.leftAnchor.constraint(
                equalTo: leftAnchor,
                constant: UIEdgeInsets.buttonInsets.left
            ),
            button.rightAnchor.constraint(
                equalTo: rightAnchor,
                constant: -UIEdgeInsets.buttonInsets.right
            ),
            buttonBottomConstraint,
        ])
    }
}

private extension BigButtonContainer {
    func setup() {
        backgroundColor = UIColor.asdk.dynamic.background.elevation1
    }
}

private extension UIEdgeInsets {
    static let buttonInsets = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
}
