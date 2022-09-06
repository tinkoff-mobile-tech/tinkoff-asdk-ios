//
//  ButtonTableViewCell.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
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

class ButtonTableViewCell: UITableViewCell {
    @IBOutlet var buttonAction: UIButton!

    var onButtonTouch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonAction.layer.cornerRadius = 4
        buttonAction.layer.borderWidth = 1
        updateColors()
    }

    func setButtonIcon(_ img: UIImage?) {
        buttonAction.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        buttonAction.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        buttonAction.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        buttonAction.setImage(img, for: .normal)
    }

    @IBAction private func buttonActionTouchUpInside(_: UIButton) {
        onButtonTouch?()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
}

private extension ButtonTableViewCell {
    func updateColors() {
        if #available(iOS 13.0, *) {
            buttonAction.layer.borderColor = UIColor.systemBackground.cgColor
        } else {
            buttonAction.layer.borderColor = UIColor.white.cgColor
        }
    }
}
