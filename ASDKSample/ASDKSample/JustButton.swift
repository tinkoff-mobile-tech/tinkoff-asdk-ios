//
//
//  JustButton.swift
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

typealias ButtonTableCell = GenericTableCell<JustButton>

final class JustButton: UIButton {

    var insets: UIEdgeInsets = .zero

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: super.intrinsicContentSize.width + insets.horizontal,
            height: super.intrinsicContentSize.height + insets.vertical
        )
    }

    private var onTap: (() -> Void)?
}

extension JustButton: ConfigurableAndReusable {

    struct Model {
        let id: Int
        let title: String?
        let image: UIImage?
        let onTap: () -> Void
    }

    @objc private func tapPressed() {
        onTap?()
    }

    func configure(model: Model) {
        onTap = model.onTap
        tag = model.id
        setTitle(model.title, for: .normal)
        setImage(model.image, for: .normal)
        setTitleColor(.black, for: .normal)
        addTarget(self, action: #selector(tapPressed), for: .touchUpInside)
    }

    func prepareForReuse() {
        onTap = nil
        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
    }
}

extension JustButton: Stylable {

    struct Style {
        var insets: UIEdgeInsets = .zero
        var textColor: UIColor = .dynamicText

        static var basic: Style { Style() }
    }

    func apply(style: Style) {
        insets = style.insets
        setTitleColor(style.textColor, for: .normal)
    }
}
