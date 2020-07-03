//
//  RootViewController.swift
//  ASDKSample
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
import ASDKUI
import ASDKCore
import PassKit

struct Product: Codable {
	
	var price: NSDecimalNumber
	var name: String
	var id: Int
	
	private enum CodingKeys: String, CodingKey {
		case id
		case price
		case name
	}
	
	init(price: Double, name: String, id: Int) {
		self.price = NSDecimalNumber.init(value: price)
		self.name = name
		self.id = id
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		let priceDouble = try container.decode(Double.self, forKey: .price)
		price = NSDecimalNumber.init(value: priceDouble)
		
		name = try container.decode(String.self, forKey: .name)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encode(price.doubleValue, forKey: .price)
	}
	
}


class ProductTableViewCell: UITableViewCell {
	
	static let reuseIdentifier = "ProductTableViewCell"
	
}


class RootViewController: UITableViewController {
	
	@IBOutlet weak var buttonCart: UIBarButtonItem!
	@IBOutlet weak var buttonSavedCards: UIBarButtonItem!
	@IBOutlet weak var buttonSettings: UIBarButtonItem!
	@IBOutlet weak var buttonAbount: UIBarButtonItem!
	
	private var dataSource: [Product] = []
	private var onScannerResult: ((_ number: String?, _ date: String?) -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = NSLocalizedString("title.onlineShop", comment: "Онлайн магазин")
		
		dataSource.append(Product.init(price: 100.0, name: "Шантарам - 2. Тень горы", id: 1))
		dataSource.append(Product.init(price: 200.0, name: "Воздушные змеи", id: 1))
		dataSource.append(Product.init(price: 300.0, name: "Чайка по имени Джонатан Ливингстон", id: 1))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let count = CartDataProvider.shared.dataSource.count

		if count > 0 {
			buttonCart.title = "🛒+\(count)"
		} else {
			buttonCart.title = "🛒"
		}
	}
	
	// MARK: UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return dataSource.count
		}
		
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let product = dataSource[indexPath.row]
			
			if let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier) as? ProductTableViewCell {
				cell.textLabel?.text = product.name
				cell.detailTextLabel?.text = Utils.formatAmount(product.price)
				
				return cell
			}
		}
		
		if indexPath.section == 1 {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") {
				cell.textLabel?.text = NSLocalizedString("button.generateQRCode", comment: "Сгенерировать QR-код")
				cell.imageView?.image = UIImage.init(named: "logo_sbp")
				
				return cell
			}
		}
		
		return tableView.defaultCell()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			let credentional = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey,
													  password: ASDKStageTestData.terminalPassword,
													  publicKey: ASDKStageTestData.testPublicKey)
			
			let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional)
			acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

			if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
				
				let viewConfigration = AcquiringViewConfigration.init()
				viewConfigration.viewTitle = NSLocalizedString("title.qrcode", comment: "QR-код")
				
				sdk.presentPaymentQRCollector(on: self, configuration: viewConfigration)
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewController = segue.destination as? BuyProductsViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
			let product = dataSource[indexPath.row]
			
			let credentional = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey,
													  password: ASDKStageTestData.terminalPassword,
													  publicKey: ASDKStageTestData.testPublicKey)
			
			let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional)
			acquiringSDKConfiguration.logger = AcquiringLoggerDefault()
			acquiringSDKConfiguration.fpsEnabled = AppSetting.shared.paySBP

			if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
				viewController.scaner = self
				viewController.sdk = sdk
				viewController.customerKey = ASDKStageTestData.customerKey
			}
			
			viewController.products = [product]
		}
	}
	
	@IBAction func openCardList(_ sender: UIBarButtonItem) {
		let credentional = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey,
												  password: ASDKStageTestData.terminalPassword,
												  publicKey: ASDKStageTestData.testPublicKey)
		
		let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional)		
		acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

		let customerKey = ASDKStageTestData.customerKey
		let cardListViewConfigration = AcquiringViewConfigration.init()
		cardListViewConfigration.viewTitle = NSLocalizedString("title.paymentCardList", comment: "Список карт")
		cardListViewConfigration.scaner = self
		cardListViewConfigration.alertViewHelper = self
		cardListViewConfigration.localizableInfo = AcquiringViewConfigration.LocalizableInfo.init(lang: AppSetting.shared.languageId)
		
		if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
			sdk.presentCardList(on: self, customerKey: customerKey, configuration: cardListViewConfigration)
			sdk.addCardNeedSetCheckTypeHandler = {
				return AppSetting.shared.addCardChekType
			}
		}
	}
	
}


extension RootViewController: AcquiringScanerProtocol {
	
	func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController? {
		if let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CardScanerViewController") as? CardScanerViewController {
			viewController.onScannerResult = { (numbres) in
				completion(numbres, nil, nil)
			}
			
			return viewController
		}
		
		return nil
	}
	
}


extension RootViewController: AcquiringAlertViewProtocol {
	
	func presentAlertView(_ title: String?, message: String?, dismissCompletion: (() -> Void)?) -> UIViewController? {
		let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
		alertView.addAction(UIAlertAction.init(title: "ок", style: .default, handler: { (action) in
			dismissCompletion?()
		}))
		
		return alertView
	}
	
}
