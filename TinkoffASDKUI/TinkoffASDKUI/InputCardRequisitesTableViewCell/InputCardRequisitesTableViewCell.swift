//
//  InputCardRequisitesTableViewCell.swift
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

class InputCardRequisitesTableViewCell: UITableViewCell, InputRequisitesViewInConnection {
    @IBOutlet var viewBorder: UIView!
    @IBOutlet var imageViewPSLogo: UIImageView!
    @IBOutlet var imageViewPSLogoWidth: NSLayoutConstraint!
    //
    @IBOutlet var textFieldCardNumber: UITextFieldCardRequisites!
    @IBOutlet var textFieldCardExpDate: UITextFieldCardRequisites!
    @IBOutlet var textFieldCardExpDateWidth: NSLayoutConstraint!
    @IBOutlet var textFieldCardCVC: UITextFieldCardRequisites!
    //
    @IBOutlet var labelShortCardNumber: UILabel!
    // Next or Scan
    @IBOutlet var buttonRight: UIButton!
    @IBOutlet var buttonShowCardNumber: UIButton!

    var onButtonRightTouch: (() -> Void)?
    var onCardNumberTouch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        viewBorder.layer.cornerRadius = 12
        viewBorder.layer.shadowColor = labelShortCardNumber.textColor.cgColor
        viewBorder.layer.shadowOpacity = 0.1
        viewBorder.layer.shadowOffset = .zero
        viewBorder.layer.shadowRadius = 8

        imageViewPSLogoWidth.constant = 0
    }

    @IBAction private func onButtonRightTouchUpInside(_: UIButton) {
        onButtonRightTouch?()
    }

    @IBAction private func onCardNumberTouchUpInside(_: UIButton) {
        onCardNumberTouch?()
    }
}
