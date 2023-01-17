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

import PassKit
import TinkoffASDKCore
import TinkoffASDKUI

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
        self.price = NSDecimalNumber(value: price)
        self.name = name
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let priceDouble = try container.decode(Double.self, forKey: .price)
        price = NSDecimalNumber(value: priceDouble)

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

    @IBOutlet var buttonCart: UIBarButtonItem!
    @IBOutlet var buttonSavedCards: UIBarButtonItem!
    @IBOutlet var buttonSettings: UIBarButtonItem!
    @IBOutlet var buttonAbount: UIBarButtonItem!

    private var dataSource: [Product] = []
    private var onScannerResult: ((_ number: String?, _ date: String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.onlineShop

        dataSource.append(Product(price: 100.0, name: "Шантарам - 2. Тень горы", id: 1))
        dataSource.append(Product(price: 200.0, name: "Воздушные змеи", id: 1))
        dataSource.append(Product(price: 300.0, name: "Чайка по имени Джонатан Ливингстон", id: 1))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let count = CartDataProvider.shared.dataSource.count

        if count > 0 {
            buttonCart.title = "🛒+\(count)"
        } else {
            buttonCart.title = "🛒"
        }

        tableView.reloadData()
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case .zero:
            return dataSource.count
        case 1:
            return AppSetting.shared.paySBP ? 1 : 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            showSpbQrCollector()
        } else {
            showBuyProductsViewController(rowIndex: indexPath.row)
        }

        tableView.deselectRow(at: indexPath, animated: true)
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
                cell.textLabel?.text = Loc.Button.generateQRCode
                cell.imageView?.image = Asset.logoSbp.image

                return cell
            }
        }

        return tableView.defaultCell()
    }

    // MARK: - Navigation

    @IBAction func openCardList(_ sender: UIBarButtonItem) {
        let cardListViewConfigration = AcquiringViewConfiguration()
        cardListViewConfigration.viewTitle = Loc.Title.paymentCardList
        cardListViewConfigration.scaner = self

        if AppSetting.shared.acquiring {
            cardListViewConfigration.alertViewHelper = self
        }

        if let sdk = try? SdkAssembly.assembleUISDK(credential: AppSetting.shared.activeSdkCredentials) {
            sdk.addCardNeedSetCheckTypeHandler = {
                AppSetting.shared.addCardChekType
            }

            sdk.presentCardList(
                on: self,
                customerKey: AppSetting.shared.activeSdkCredentials.customerKey,
                configuration: cardListViewConfigration
            )
        }
    }

    @IBAction func openAddCard(_ sender: UIBarButtonItem) {
        if let sdk = try? SdkAssembly.assembleUISDK(credential: AppSetting.shared.activeSdkCredentials) {
            sdk.addCardNeedSetCheckTypeHandler = {
                AppSetting.shared.addCardChekType
            }

            sdk.presentAddCard(
                on: self,
                customerKey: AppSetting.shared.activeSdkCredentials.customerKey,
                output: self
            )
        }
    }
}

extension RootViewController: AcquiringScanerProtocol {

    func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController? {
        if let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "CardScanerViewController") as? CardScanerViewController {
            viewController.onScannerResult = { numbres in
                completion(numbres, nil, nil)
            }

            return viewController
        }

        return nil
    }
}

extension RootViewController: AcquiringAlertViewProtocol {

    func presentAlertView(_ title: String?, message: String?, dismissCompletion: (() -> Void)?) -> UIViewController? {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "ок", style: .default, handler: { _ in
            dismissCompletion?()
        }))

        return alertView
    }
}

// MARK: - Private methods only

private extension RootViewController {

    private func showSpbQrCollector() {
        if let sdk = try? SdkAssembly.assembleUISDK(credential: AppSetting.shared.activeSdkCredentials) {
            let viewConfigration = AcquiringViewConfiguration()
            viewConfigration.viewTitle = Loc.Title.qrcode

            sdk.presentPaymentQRCollector(on: self, configuration: viewConfigration)
        }
    }

    private func showBuyProductsViewController(rowIndex: Int) {
        let credential = AppSetting.shared.activeSdkCredentials

        guard let coreSDK = try? SdkAssembly.assembleCoreSDK(credential: credential),
              let uiSDK = try? SdkAssembly.assembleUISDK(credential: credential) else {
            fatalError("Could not assemble SDK")
        }

        let product = dataSource[rowIndex]

        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: BuyProductsViewController.self)
        ) as? BuyProductsViewController
        else {
            fatalError("Could not instantiate BuyProductsViewController")
        }

        viewController.scaner = self
        viewController.coreSDK = coreSDK
        viewController.uiSDK = uiSDK
        viewController.customerKey = credential.customerKey
        viewController.products = [product]
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RootViewController: IAddNewCardOutput {

    func addingNewCardCompleted(result: AddNewCardResult) {
        switch result {
        case .cancelled, .failure:
            let alert = UIAlertController.okAlert(
                title: nil,
                message: String(describing: result),
                buttonTitle: Loc.Button.ok
            )

            present(alert, animated: true)

        case let .success(card):
            let alert = UIAlertController.okAlert(
                title: nil,
                message: Loc.AddCard.Alert.message(String.format(pan: card.cardId)),
                buttonTitle: Loc.Button.ok
            )
            present(alert, animated: true)
        }
    }
}

private extension String {

    static func format(pan: String) -> String {
        "•" + pan.suffix(4)
    }
}
