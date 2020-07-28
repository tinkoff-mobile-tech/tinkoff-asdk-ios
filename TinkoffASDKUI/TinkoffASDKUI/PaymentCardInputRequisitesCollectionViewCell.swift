//
//  PaymentCardInputRequisitesCollectionViewCell.swift
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

protocol InputRequisitesViewInConnection: class {
	
	var imageViewPSLogo: UIImageView! { get }
	var imageViewPSLogoWidth: NSLayoutConstraint! { get }
	
	var labelShortCardNumber: UILabel! { get }
	
	var textFieldCardNumber: UITextFieldCardRequisites! { get }
	
	var textFieldCardExpDate: UITextFieldCardRequisites! { get }
	
	var textFieldCardExpDateWidth: NSLayoutConstraint! { get }
	
	var textFieldCardCVC: UITextFieldCardRequisites! { get }
	
	var buttonRight: UIButton! { get }
	var buttonShowCardNumber: UIButton! { get }
	
	var onButtonRightTouch: (() -> Void)? { get set }
	var onCardNumberTouch: (() -> Void)? { get set }
	
}


class UITextFieldCardRequisites: UITextField {
	
	override func deleteBackward() {
		super.deleteBackward()
		
		if text == nil || text?.isEmpty == true {
			_ = self.delegate?.textFieldShouldReturn?(self)
		}
	}
	
}

class PaymentCardInputRequisitesCollectionViewCell: UICollectionViewCell, InputRequisitesViewInConnection {
	
	@IBOutlet weak var viewBorder: UIView!
	@IBOutlet weak var imageViewPSLogo: UIImageView!
	@IBOutlet weak var imageViewPSLogoWidth: NSLayoutConstraint!
	@IBOutlet weak var viewSeparator: UIView!
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


extension PaymentCardInputRequisitesCollectionViewCell: InputViewStatus {

	func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String?) {
		switch value {
			case .error:
				textFieldCardNumber.textColor = colorError
				textFieldCardExpDate.textColor = colorError
				textFieldCardCVC.textColor = colorError
				viewSeparator.backgroundColor = colorError
			
			case .normal:
				textFieldCardNumber.textColor = colorNormal
				textFieldCardExpDate.textColor = colorNormal
				textFieldCardCVC.textColor = colorNormal
				viewSeparator.backgroundColor = .clear
			
			case .disable:
				textFieldCardNumber.textColor = colorDisable
				textFieldCardExpDate.textColor = colorDisable
				textFieldCardCVC.textColor = colorDisable
				viewSeparator.backgroundColor = .clear
		}
	}
	
	
}
