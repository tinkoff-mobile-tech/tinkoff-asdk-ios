//
//  SelectRebuildCardViewController.swift
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

class SelectRebuildCardViewController: UITableViewController {

    var onSelectCard: ((PaymentCard) -> Void)?
    var cards: [PaymentCard] = []

    private lazy var cardRequisitesBrandInfo: CardRequisitesBrandInfoProtocol = CardRequisitesBrandInfo()
    private lazy var buttonClose = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeView(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("title.paymentCardList", comment: "Сохраненные карты")
        tableView.register(UINib(nibName: "RebuildCardTableViewCell", 
                                 bundle: Bundle(for: type(of: self))), 
                           forCellReuseIdentifier: "RebuildCardTableViewCell")

        navigationItem.setLeftBarButton(buttonClose, animated: true)
    }

    @objc func closeView(_ button: UIBarButtonItem) {
        dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RebuildCardTableViewCell") as? RebuildCardTableViewCell {
            let card = cards[indexPath.row]

            cell.labelCardName.text = card.pan
            cell.labelCardExpData.text = card.expDateFormat()
            if let rebuildId = card.parentPaymentId {
                cell.labelRebuid.text = "(\(NSLocalizedString("text.parentPayment", comment: "родительский платеж")) \(rebuildId))"
            }

            cardRequisitesBrandInfo.cardBrandInfo(numbers: card.pan, completion: { [weak cell] requisites, icon, _ in
                if let numbers = requisites, card.pan.hasPrefix(numbers) {
                    cell?.imageViewLogo.image = icon
                    cell?.imageViewLogo.isHidden = false
                } else {
                    cell?.imageViewLogo.image = nil
                    cell?.imageViewLogo.isHidden = true
                }
            })

            return cell
        }

        return tableView.defaultCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        onSelectCard?(card)

        dismiss(animated: true) {
            //
        }
    }
}
