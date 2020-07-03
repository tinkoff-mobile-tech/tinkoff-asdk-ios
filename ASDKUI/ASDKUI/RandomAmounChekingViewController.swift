//
//  RandomAmounChekingViewController.swift
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

class RandomAmounChekingViewController: ConfirmViewController {
	
	enum TableViewCells {
		case title
		case textField
		case secureLogos
	}
	
	weak var alertViewHelper: AcquiringAlertViewProtocol?
	var completeHandler: ((_ result: Double) -> Void)?
	
	@IBOutlet private weak var tableView: UITableView!
	private var tableViewCells: [TableViewCells]!
	private var inputValue: String?
	private weak var inputAccessoryViewWithButton: ButtonInputAccessoryView?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = AcqLoc.instance.localize("TinkoffAcquiring.view.title.confimration")
		
		tableViewCells = [.title, .textField, .secureLogos]
				
		tableView.register(UINib.init(nibName: "TextFieldTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "TextFieldTableViewCell")
		tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "AmountTableViewCell")
		tableView.register(UINib.init(nibName: "PSLogoTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "PSLogoTableViewCell")
		
		tableView.dataSource = self
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		inputField()?.textField.becomeFirstResponder()
	}
	
	private func inputField() -> InputFieldTableViewCellStatusProtocol? {
		if let index = tableViewCells.firstIndex(of: .textField), let inputField = tableView.cellForRow(at: IndexPath.init(row: index, section: 0)) as? InputFieldTableViewCellStatusProtocol {
			return inputField
		}
		
		return nil
	}
	
	private func onButtonAddTouch() {
		if validate(inputValue) {
			if let value = inputValue {
				let desValue = value.replacingOccurrences(of: ",", with: ".")
				if let amount = Double(desValue), amount > 0.0 {
					completeHandler?(amount)
				}
			}
		} else {
			if let inputField = inputField() {
				inputField.setStatus(.error, statusText: AcqLoc.instance.localize("TinkoffAcquiring.error.loopAmount"))
			}
		}
	}//onButtonAddTouch
		
	private func validate(_ validateValue: String?) -> Bool {
		if let value = validateValue {
			let desValue = value.replacingOccurrences(of: ",", with: ".")
			if let amount = Double(desValue), amount > 0.0 {
				return true
			}
		}
		
		return false
	}
	
}

extension RandomAmounChekingViewController: UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableViewCells.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch tableViewCells[indexPath.row] {
			case .title:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell") as? AmountTableViewCell {
					cell.labelTitle.text = AcqLoc.instance.localize("TinkoffAcquiring.text.loopConfirmation")
					
					return cell
				}
			
			case .textField:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as? TextFieldTableViewCell {
					cell.textField.delegate = self
					cell.textField.keyboardType = .decimalPad
					cell.labelHint.text = AcqLoc.instance.localize("TinkoffAcquiring.hint.loopAmount")
					cell.textField.placeholder = AcqLoc.instance.localize("TinkoffAcquiring.placeholder.loopAmount")
					
					return cell
				}
			
			case .secureLogos:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "PSLogoTableViewCell") as? PSLogoTableViewCell {
					return cell
				}
		}
		
		return tableView.defaultCell()
	}
	
}

extension RandomAmounChekingViewController: BecomeFirstResponderListener {
	
	func textFieldShouldBecomeFirstResponder(_ textField: UITextField) -> Bool {
		return true
	}
	
}

extension RandomAmounChekingViewController: UITextFieldDelegate {
	
	// MARK: UITextFieldDelegate
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		if let accessoryView = Bundle(for: type(of: self)).loadNibNamed("ButtonInputAccessoryView", owner: nil, options: nil)?.first as? ButtonInputAccessoryView {
			accessoryView.buttonAction.setTitle(AcqLoc.instance.localize("TinkoffAcquiring.button.confirm"), for: .normal)
			accessoryView.onButtonTouchUpInside = { [weak self] in
				self?.onButtonAddTouch()
			}
			
			textField.inputAccessoryView = accessoryView
			inputAccessoryViewWithButton = accessoryView
		}
		
		inputAccessoryViewWithButton?.updateViewSize(for: textField.traitCollection)
		inputAccessoryViewWithButton?.buttonAction.setTitle(AcqLoc.instance.localize("TinkoffAcquiring.button.addCard"), for: .normal)
		
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		inputAccessoryViewWithButton?.buttonAction.isEnabled = validate(inputValue)
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		inputValue = textField.text
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let inputFieldCell: InputFieldTableViewCellStatusProtocol = UIView.searchTableViewCell(by: textField) {
			tableView.beginUpdates()
				inputFieldCell.setStatus(.normal, statusText: nil)
			tableView.endUpdates()
			
		}
		
		let text: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
		inputValue = text
		inputAccessoryViewWithButton?.buttonAction.isEnabled = validate(inputValue)
		
		return true
	}
	
	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		if let inputField: InputFieldTableViewCellStatusProtocol = UIView.searchTableViewCell(by: textField) {
			inputField.setStatus(.normal, statusText: nil)
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		return true
	}
	
}
