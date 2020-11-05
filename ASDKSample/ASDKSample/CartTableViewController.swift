//
//  CartTableViewController.swift
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

import TinkoffASDKCore
import TinkoffASDKUI
import UIKit

class CartProductTableViewCell: UITableViewCell {

    static let reuseIdentifier = "CartProductTableViewCell"
}

class CartDataProvider {

    private(set) var dataSource: [Product] = []
    private let key = "SettingKeyCart"

    static let shared = CartDataProvider()

    init() {
        //		if let data = UserDefaults.standard.data(forKey: key) {
        //			if let cartProducts = try? JSONDecoder().decode([Product].self, from: data) {
        //				self.dataSource = cartProducts
        //			}
        //		}
    }

    func addProduct(_ product: Product) {
        dataSource.append(product)
    }

    func clear() {
        dataSource.removeAll()
    }
}

class CartTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("title.cart", comment: "Корзина")

        tableView.registerCells(types: [CartEmptyTableViewCell.self])
        tableView.registerHeaderFooter(types: [CartBuyButtonView.self])
    }

    @IBAction func cartEmptyButtonTouchUpInside(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: UITableViewDelegate, UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(CartDataProvider.shared.dataSource.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= CartDataProvider.shared.dataSource.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CartEmptyTableViewCell.nibName) as? CartEmptyTableViewCell {
                cell.labelTitle.text = NSLocalizedString("status.cartIsEmpty", comment: "Корзина пуста")
                cell.buttonAction.setTitle(NSLocalizedString("button.backToShop", comment: "Вернуться в магазин"), for: .normal)
                cell.onButtonTouch = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }

                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: CartProductTableViewCell.reuseIdentifier) as? CartProductTableViewCell {
            let product = CartDataProvider.shared.dataSource[indexPath.row]
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = Utils.formatAmount(product.price)

            return cell
        }

        return tableView.defaultCell()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if CartDataProvider.shared.dataSource.isEmpty == false, let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: CartBuyButtonView.nibName) as? CartBuyButtonView {
            footer.labelTitle.text = nil
            footer.buttonBuy.setTitle(NSLocalizedString("button.pay", comment: "Оплатить"), for: .normal)

            footer.onButtonTouch = { [weak self] in
                if let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BuyProductsViewController") as? BuyProductsViewController {
                    let credentional = AcquiringSdkCredential(terminalKey: StageTestData.terminalKey,
                                                              password: StageTestData.terminalPassword,
                                                              publicKey: StageTestData.testPublicKey)

                    let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional)
                    acquiringSDKConfiguration.logger = AcquiringLoggerDefault()
                    acquiringSDKConfiguration.fpsEnabled = AppSetting.shared.paySBP

                    if let sdk = try? AcquiringUISDK(configuration: acquiringSDKConfiguration) {
                        viewController.sdk = sdk
                        viewController.customerKey = StageTestData.customerKey
                    }

                    viewController.products = CartDataProvider.shared.dataSource
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }

            return footer
        }

        return UIView()
    }
}
