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

    private lazy var buttonClose = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(closeView(_:))
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.paymentCardList
        tableView.register(
            UINib(
                nibName: "RebuildCardTableViewCell",
                bundle: Bundle(for: type(of: self))
            ),
            forCellReuseIdentifier: "RebuildCardTableViewCell"
        )

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
        let cell = tableView.dequeue(RebuildCardTableViewCell.self)
        let card = cards[indexPath.row]

        cell.labelCardName.text = card.pan
        cell.labelCardExpData.text = card.expDateFormat()
        if let rebuildId = card.parentPaymentId {
            cell.labelRebuid.text = "(\(Loc.Text.parentPayment) \(rebuildId))"
        }

        cell.imageViewLogo.image = cardBrandImage(for: card.pan)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        onSelectCard?(card)

        dismiss(animated: true) {
            //
        }
    }
}

// MARK: Card recognizer

private extension SelectRebuildCardViewController {
    private enum CardType {
        case mastercard
        case visa
        case mir
        case maestro
        case unrecognized
    }

    private func cardBrandImage(for cardNumber: String) -> UIImage? {
        let paymentSystem = paymentSystemType(for: cardNumber)

        switch paymentSystem {
        case .mastercard: return Asset.CardRequisites.mcLogo.image
        case .visa: return Asset.CardRequisites.visaLogo.image
        case .mir: return Asset.CardRequisites.mirLogo.image
        case .maestro: return Asset.CardRequisites.maestroLogo.image
        case .unrecognized: return nil
        }
    }

    private func paymentSystemType(for cardNumber: String) -> CardType {
        let prefix = String(cardNumber.prefix(1))

        switch prefix {
        case "6": return .maestro
        case "5": return .mastercard
        case "4": return .visa
        case "2": return isMir(cardNumber) ? .mir : .mastercard
        default: return .unrecognized
        }
    }

    private func isMir(_ cardNumber: String) -> Bool {
        guard let regЕxp = try? NSRegularExpression(pattern: "220[0-4]", options: .caseInsensitive) else { return false }

        let prefix = String(cardNumber.prefix(4))
        let range = NSRange(location: 0, length: prefix.count)
        let matches = regЕxp.matches(in: prefix, options: [], range: range)
        return matches.count == 1
    }
}
