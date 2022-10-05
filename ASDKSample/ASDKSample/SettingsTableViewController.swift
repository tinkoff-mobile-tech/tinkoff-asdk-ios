//
//  SettingsTableViewController.swift
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
import UIKit

class AppSetting {

    private let keySBP = "SettingKeySBP"
    private let keyTinkoffPay = "SettingKeyTinkoffPay"
    private let keyShowEmailField = "SettingKeyShowEmailField"
    private let keyKindForAlertView = "KindForAlertView"
    private let keyAddCardCheckType = "AddCardChekType"
    private let keyLanguageId = "LanguageId"

    /// Система быстрых платежей
    var paySBP = false {
        didSet {
            UserDefaults.standard.set(paySBP, forKey: keySBP)
            UserDefaults.standard.synchronize()
        }
    }

    /// TinkoffPay
    var tinkoffPay = false {
        didSet {
            UserDefaults.standard.set(tinkoffPay, forKey: keyTinkoffPay)
        }
    }

    /// Показыть на форме оплаты поле для ввода email для отправки чека
    var showEmailField = false {
        didSet {
            UserDefaults.standard.set(showEmailField, forKey: keyShowEmailField)
            UserDefaults.standard.synchronize()
        }
    }

    var acquiring = false {
        didSet {
            UserDefaults.standard.set(acquiring, forKey: keyKindForAlertView)
            UserDefaults.standard.synchronize()
        }
    }

    var addCardChekType: PaymentCardCheckType = .no {
        didSet {
            UserDefaults.standard.set(addCardChekType.rawValue, forKey: keyAddCardCheckType)
            UserDefaults.standard.synchronize()
        }
    }

    var languageId: String? {
        didSet {
            UserDefaults.standard.set(languageId, forKey: keyLanguageId)
            UserDefaults.standard.synchronize()
        }
    }

    static let shared = AppSetting()

    init() {
        let usd = UserDefaults.standard

        paySBP = usd.bool(forKey: keySBP)
        tinkoffPay = usd.bool(forKey: keyTinkoffPay)
        showEmailField = usd.bool(forKey: keyShowEmailField)
        acquiring = usd.bool(forKey: keyKindForAlertView)
        if let value = usd.value(forKey: keyAddCardCheckType) as? String {
            addCardChekType = PaymentCardCheckType(rawValue: value)
        }

        languageId = usd.string(forKey: keyLanguageId)
    }
}

class SettingsTableViewController: UITableViewController {

    enum TableViewCellType {
        /// включить оплату с помощью `Системы Быстрых Платежей`
        case paySBP
        /// включить оплату с помощью `TinkoffPay`
        case tinkoffPay
        /// показывать на форме оплаты поле для ввода email
        case showEmail
        /// использовать алерты из Aquaring SDK
        case acquiring
        /// какой тип проверки использоваться при сохранении карты
        case addCardCheckType
        /// на каком языке показыват форму оплаты
        case language
    }

    private var tableViewCells: [TableViewCellType] = []
    private var availableCardChekType: [String] = []
    private var availableLanguage: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.settings

        tableView.registerCells(types: [SwitchTableViewCell.self, SegmentedTabeViewCell.self])

        updateTableViewCells()
    }

    func updateTableViewCells() {

        availableCardChekType = []
        availableCardChekType.append(PaymentCardCheckType.no.rawValue)
        availableCardChekType.append(PaymentCardCheckType.check3DS.rawValue)
        availableCardChekType.append(PaymentCardCheckType.hold3DS.rawValue)
        availableCardChekType.append(PaymentCardCheckType.hold.rawValue)

        availableLanguage.append("auto")
        availableLanguage.append("ru")
        availableLanguage.append("en")

        tableViewCells = [.paySBP, .tinkoffPay, .showEmail, .acquiring, .addCardCheckType, .language]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewCells[indexPath.section] {
        case .paySBP:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
                let value = AppSetting.shared.paySBP
                cell.switcher.isOn = value

                let title = value
                    ? Loc.Status.Sbp.on
                    : Loc.Status.Sbp.off

                cell.labelTitle.text = title
                cell.onSwitcherChange = { swither in
                    AppSetting.shared.paySBP = swither.isOn
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }

                return cell
            }
        case .tinkoffPay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
                let value = AppSetting.shared.tinkoffPay
                cell.switcher.isOn = value

                let title = value
                    ? Loc.Status.Sbp.on
                    : Loc.Status.Sbp.off

                cell.labelTitle.text = title
                cell.onSwitcherChange = { swither in
                    AppSetting.shared.tinkoffPay = swither.isOn
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }

                return cell
            }
        case .showEmail:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
                let value = AppSetting.shared.showEmailField
                cell.switcher.isOn = value

                let title = value
                    ? Loc.Status.ShowEmailField.on
                    : Loc.Status.ShowEmailField.off
                cell.labelTitle.text = title

                cell.onSwitcherChange = { swither in
                    AppSetting.shared.showEmailField = swither.isOn
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }

                return cell
            }

        case .acquiring:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
                let value = AppSetting.shared.acquiring
                cell.switcher.isOn = value

                let title = value
                    ? Loc.Status.Alert.on
                    : Loc.Status.Alert.off
                cell.labelTitle.text = title

                cell.onSwitcherChange = { swither in
                    AppSetting.shared.acquiring = swither.isOn
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }

                return cell
            }

        case .addCardCheckType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedTabeViewCell.nibName) as? SegmentedTabeViewCell {
                cell.segmentedControl.removeAllSegments()
                for (index, title) in availableCardChekType.enumerated() {
                    cell.segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
                    if AppSetting.shared.addCardChekType.rawValue == title {
                        cell.segmentedControl.selectedSegmentIndex = index
                    }
                }

                cell.onSegmentedChanged = { [weak self] index in
                    if let value = self?.availableCardChekType[index] {
                        AppSetting.shared.addCardChekType = PaymentCardCheckType(rawValue: value)
                    }
                }

                return cell
            }

        case .language:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedTabeViewCell.nibName) as? SegmentedTabeViewCell {
                cell.segmentedControl.removeAllSegments()

                for (index, title) in availableLanguage.enumerated() {
                    cell.segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
                    if index == 0, AppSetting.shared.languageId == nil {
                        cell.segmentedControl.selectedSegmentIndex = 0
                    } else if let value = AppSetting.shared.languageId, value == title {
                        cell.segmentedControl.selectedSegmentIndex = index
                    }
                }

                cell.onSegmentedChanged = { [weak self] index in
                    if index > 0 {
                        if let value = self?.availableLanguage[index] {
                            AppSetting.shared.languageId = value
                        }
                    } else {
                        AppSetting.shared.languageId = nil
                    }
                }

                return cell
            }
        }

        return tableView.defaultCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableViewCells[section] {
        case .paySBP:
            return Loc.Title.fasterPayments
        case .tinkoffPay:
            return Loc.Name.tinkoffPay
        case .showEmail:
            return Loc.Title.showEmailField
        case .acquiring:
            return Loc.Name.acquiring
        case .addCardCheckType:
            return Loc.Title.savingCard
        case .language:
            return Loc.Title.paymentFormLanguage
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch tableViewCells[section] {
        case .paySBP:
            return Loc.Text.PayBySBP.description
        case .tinkoffPay:
            return ""
        case .showEmail:
            return Loc.Text.showEmailField

        case .acquiring:
            return Loc.Text.Acquiring.description

        case .addCardCheckType:
            return Loc.Text.AddCardCheckType.description

        case .language:
            return Loc.Text.Language.description
        }
    }
}
