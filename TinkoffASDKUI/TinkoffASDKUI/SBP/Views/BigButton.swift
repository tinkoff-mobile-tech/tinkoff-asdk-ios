//
//
//  BigButton.swift
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

final class BigButton: UIButton {
    var backgroundColors: [UIControl.State: UIColor]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Button state

    override var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }
            updateBackground()
        }
    }

    override var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            updateBackground()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: .height
        )
    }
}

private extension BigButton {
    func setup() {
        layer.cornerRadius = .cornerRadius
        layer.masksToBounds = true
    }

    func updateBackground() {
        guard let backgroundColors = backgroundColors else { return }
        let color: UIColor?
        if !isEnabled {
            color = backgroundColors[.disabled]
        } else if isHighlighted {
            color = backgroundColors[.highlighted]
        } else {
            color = backgroundColors[.normal]
        }

        backgroundColor = color
    }
}

private extension CGFloat {
    static let height: CGFloat = 56
    static let cornerRadius: CGFloat = 16
}

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
