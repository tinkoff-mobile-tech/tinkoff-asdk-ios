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


import Foundation

extension Button.Style {
    static var sbpPayment: Button.Style {
        Button.Style(
            title: Title(
                text: AcqLoc.instance.localize("TinkoffAcquiring.button.payBy"),
                color: .asdk.dynamic.background.elevation1,
                transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
            ),
            icon: Icon(
                image: UIImage(named: "buttonIconSBP", in: .uiResources, compatibleWith: nil),
                transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
            ),
            border: Border(cornerRadius: 4, width: 1, color: .borderColor),
            size: IntrinsicSize(height: 44),
            backgroundColor: .asdk.dynamic.button.sbp.background,
            tintColor: .asdk.dynamic.button.sbp.tint.withAlphaComponent(0.7),
            transform: CGAffineTransform(scaleX: -1.0, y: 1.0)
        )
    }
}

private extension UIColor {
    static var borderColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
}
