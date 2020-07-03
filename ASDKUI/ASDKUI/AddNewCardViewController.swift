//
//  AddNewCardViewController.swift
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
import ASDKCore

enum AddCardTableViewCells {
	case title
	case requisites
	case secureLogos
	case button
}


class AddNewCardViewController: PopUpViewContoller {

	// MARK: AcquiringViewConfiguration
	
	var onTouchButtonShowCardList: (() -> Void)?
	var onTouchButtonPay: (() -> Void)?
	var onTouchButtonSBP: (() -> Void)?
	var onCancelPayment: (() -> Void)?
	
	//
	private var tableViewCells: [AddCardTableViewCells]!
	private var inputCardRequisitesController: InputCardRequisitesDataSource!
	var cardListDataSourceDelegate: AcquiringCardListDataSourceDelegate?
	var completeHandler: ((_ result: Result<PaymentCard, Error>) -> Void)?
	weak var scanerDataSource: AcquiringScanerProtocol?
	weak var alertViewHelper: AcquiringAlertViewProtocol?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableViewCells = [.title, .requisites, .secureLogos]
		
		inputCardRequisitesController = InputCardRequisitesController.init()
		
		tableView.register(UINib.init(nibName: "InpuCardtRequisitesTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "InpuCardtRequisitesTableViewCell")
		tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "AmountTableViewCell")
		tableView.register(UINib.init(nibName: "PSLogoTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "PSLogoTableViewCell")

		tableView.dataSource = self
    }

	private func onButtonAddTouch() {
		let requisites = inputCardRequisitesController.requisies()
		if let number = requisites.number, let expDate = requisites.expDate, let cvc = requisites.cvc {
			let cardRequisitesValidator: CardRequisitesValidatorProtocol = CardRequisitesValidator()
			
			if cardRequisitesValidator.validateCardNumber(number: number)
				&& cardRequisitesValidator.validateCardExpiredDate(value: expDate)
				&& cardRequisitesValidator.validateCardCVC(cvc: cvc)
			{
				viewWaiting.isHidden = false
				cardListDataSourceDelegate?.cardListAddCard(number: number,
															expDate: expDate,
															cvc: cvc,
															addCardViewPresenter: self,
															completeHandler: { [weak self] (response) in
					self?.closeViewController {
						self?.completeHandler?(response)
					}
				})
			}//validate card requisites
		}
	}//onButtonAddTouch
	
}


extension AddNewCardViewController: UITableViewDataSource {
	
	// MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableViewCells.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch tableViewCells[indexPath.row] {
			case .title:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell") as? AmountTableViewCell {
					cell.labelTitle.text = AcqLoc.instance.localize("TinkoffAcquiring.text.addNewCard")
					cell.labelTitle.font = UIFont.boldSystemFont(ofSize: 22.0)

					return cell
				}

			case .requisites:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "InpuCardtRequisitesTableViewCell") as? InpuCardtRequisitesTableViewCell {
					let accessoryView = Bundle(for: type(of: self)).loadNibNamed("ButtonInputAccessoryView", owner: nil, options: nil)?.first as? ButtonInputAccessoryView

					inputCardRequisitesController.setup(responderListener: self,
														inputView: cell,
														inputAccessoryView: accessoryView,
														scaner: scanerDataSource != nil ? self : nil)
					inputCardRequisitesController.onButtonInputAccessoryTouch = { [weak self] in
						self?.onButtonAddTouch()
					}

					return cell
				}
			
			case .secureLogos:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "PSLogoTableViewCell") as? PSLogoTableViewCell {
					return cell
				}
			
			case .button:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "") {
					
					return cell
				}
		}
		
		return tableView.defaultCell()
	}
	
}


extension AddNewCardViewController: BecomeFirstResponderListener {
	
	func textFieldShouldBecomeFirstResponder(_ textField: UITextField) -> Bool {
		return true
	}
	
}


extension AddNewCardViewController: CardRequisitesScanerProtocol {
	
	func startScanner(completion: @escaping (String?, Int?, Int?) -> Void) {
		if let scanerView = scanerDataSource?.presentScanner(completion: { (numbers, mm, yy) in
			completion(numbers, mm, yy)
		}) {
			present(scanerView, animated: true, completion: nil)
		}
	}
	
}


extension AddNewCardViewController: AcquiringViewConfiguration {

	// MARK: AcquiringViewConfiguration
	
	func changedStatus(_ status: AcquiringViewStatus) {
		
	}
	
	func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>) {

	}
	
	func setViewHeight(_ height: CGFloat) {
		modalMinHeight = height
		preferredContentSize = CGSize.init(width: preferredContentSize.width, height: height)
	}
	
	func closeVC(animated flag: Bool, completion: (() -> Void)?) {
		if let presetingVC = presentingViewController {
			presetingVC.dismiss(animated: true) {
				completion?()
			}
		} else {
			if let nav = navigationController {
				nav.popViewController(animated: true)
				completion?()
			} else {
				dismiss(animated: true) {
					completion?()
				}
			}
		}
		
	}
	
	func presentVC(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
		present(viewControllerToPresent, animated: flag, completion: completion)
	}
	
	// MARK: Setup View
	
	func setCells(_ value: [AcquiringViewTableViewCells]) {
		
	}
	
	func checkDeviceFor3DSData(with request: URLRequest) {
		
	}
	
	func cardRequisites() -> PaymentSourceData? {
		return nil
	}
	
	func infoEmail() -> String? {
		return nil
	}
	
}
