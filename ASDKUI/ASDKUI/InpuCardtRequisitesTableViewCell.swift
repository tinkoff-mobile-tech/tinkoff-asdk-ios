//
//  InpuCardtRequisitesTableViewCell.swift
//  ASDKUI
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

class InpuCardtRequisitesTableViewCell: UITableViewCell, InputRequisitesViewInConnection {

	@IBOutlet weak var viewBorder: UIView!
	@IBOutlet weak var imageViewPSLogo: UIImageView!
	@IBOutlet weak var imageViewPSLogoWidth: NSLayoutConstraint!
	//
	@IBOutlet weak var textFieldCardNumber: UITextFieldCardRequisites!
	@IBOutlet weak var textFieldCardExpDate: UITextFieldCardRequisites!
	@IBOutlet weak var textFieldCardExpDateWidth: NSLayoutConstraint!
	@IBOutlet weak var textFieldCardCVC: UITextFieldCardRequisites!
	//
	@IBOutlet weak var labelShortCardNumber: UILabel!
	// Next or Scan
	@IBOutlet weak var buttonRight: UIButton!
	@IBOutlet weak var buttonShowCardNumber: UIButton!
	
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
	
	@IBAction private func onButtonRightTouchUpInside(_ sender: UIButton) {
		onButtonRightTouch?()
	}
	
	@IBAction private func onCardNumberTouchUpInside(_ sender: UIButton) {
		onCardNumberTouch?()
	}
	
}
