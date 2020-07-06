//
//  TextFieldTableViewCell.swift
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

enum InputFieldTableViewCellStatus: Int {
	
	case normal
	
	case error
	
	case disable
	
}

protocol InputFieldTableViewCellStatusProtocol: class {
	
	var labelHint: UILabel! { get }
	
	var textField: UITextField! { get }
	
	var labelStatus: UILabel! { get }
	
	var status: InputFieldTableViewCellStatus { get }
	
	func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String?)
	
}

class TextFieldTableViewCell: UITableViewCell, InputFieldTableViewCellStatusProtocol {

	@IBOutlet weak var viewCloud: UIView!
	@IBOutlet weak var labelHint: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var labelStatus: UILabel!
	@IBOutlet weak var viewSeparator: UIView!
	
	private var colorNormal: UIColor = {
		if #available(iOS 13, *) {
			return .label
		} else {
			return .black
		}
	}()
	private var colorError: UIColor = .systemRed
	private var colorDisable: UIColor = .lightGray
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		viewSeparator.backgroundColor = UIColor.init(hex: "#C7C9CC")
		setStatus(.normal)
	}
    
	// MARK: InputFieldTableViewCell
	
	private(set) var status: InputFieldTableViewCellStatus = .normal
	
	func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String? = nil) {
		self.status = value
		switch value {
			case .error:
				textField.textColor = colorError
				labelHint.textColor = colorError.withAlphaComponent(0.7)
				labelStatus.textColor = colorError
				viewSeparator.backgroundColor = colorError
			
			case .normal:
				textField.textColor = colorNormal
				labelHint.textColor = colorNormal.withAlphaComponent(0.7)
				labelStatus.textColor = colorNormal
				viewSeparator.backgroundColor = UIColor.init(hex: "#C7C9CC")

			case .disable:
				textField.textColor = colorDisable
				labelHint.textColor = colorDisable
				labelStatus.textColor = colorDisable
				viewSeparator.backgroundColor = UIColor.init(hex: "#C7C9CC")
		}

		labelStatus.text = statusText
	}
	
}
