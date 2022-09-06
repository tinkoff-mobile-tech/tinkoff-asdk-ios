//
//
//  Button+Styles.swift
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

extension ASDKButton.Style {
    static var sbpPayment: ASDKButton.Style {
        ASDKButton.Style(
            title: Title(
                text: L10n.TinkoffAcquiring.Button.payBy,
                color: .asdk.dynamic.background.elevation1,
                transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
            ),
            icon: Icon(
                image: Asset.buttonIconSBP.image,
                transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
            ),
            border: Border(cornerRadius: 4, width: 1, color: .sbpBorder),
            size: IntrinsicSize(height: 44),
            backgroundColor: .asdk.dynamic.button.sbp.background,
            transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
        )
    }

    static func primary(
        title: String,
        backgroundColor: UIColor = .asdk.yellow,
        titleColor: UIColor = .asdk.textPrimary
    ) -> ASDKButton.Style {
        ASDKButton.Style(
            title: Title(
                text: title,
                color: titleColor,
                font: .systemFont(ofSize: 17, weight: .regular)
            ),
            border: Border(cornerRadius: 16),
            size: IntrinsicSize(height: 56),
            backgroundColor: backgroundColor
        )
    }

    static func primary(
        title: String,
        buttonStyle: TinkoffASDKUI.ButtonStyle?
    ) -> ASDKButton.Style {
        buttonStyle.map {
            .primary(
                title: title,
                backgroundColor: $0.backgroundColor,
                titleColor: $0.titleColor
            )
        } ?? .primary(title: title)
    }
}

private extension UIColor {
    static var sbpBorder: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
}
