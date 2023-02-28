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

final class SettingsTableViewController: UITableViewController {

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
        /// какой тип сервера будет использоваться при запросах
        case server
        /// адрес кастомного сервера
        case customServer
        /// на каком языке показыват форму оплаты
        case language
        /// изменить sdk credentials
        case credentials
    }

    private var tableViewCells: [TableViewCellType] = []
    private var availableCardChekType: [String] = []
    private var availableServers: [AcquiringSdkEnvironment] = []
    private var availableLanguage: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Loc.Title.settings

        tableView.registerCells(types: [SwitchTableViewCell.self, SegmentedTabeViewCell.self])
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.reusableId)
        tableView.register(VerticalEditableTableCell.self, forCellReuseIdentifier: VerticalEditableTableCell.reusableId)

        updateTableViewCells()
    }

    func pushSdkCredentialsVC() {
        let editSdkCredentialsViewController = EditSdkCredentialsViewController()
        navigationController?.pushViewController(
            editSdkCredentialsViewController,
            animated: true
        )
    }

    func updateTableViewCells() {

        availableCardChekType = []
        availableCardChekType.append(PaymentCardCheckType.no.rawValue)
        availableCardChekType.append(PaymentCardCheckType.check3DS.rawValue)
        availableCardChekType.append(PaymentCardCheckType.hold3DS.rawValue)
        availableCardChekType.append(PaymentCardCheckType.hold.rawValue)

        availableServers = []
        availableServers.append(.test)
        availableServers.append(.preProd)
        availableServers.append(.prod)
        availableServers.append(.custom(""))

        availableLanguage.append("auto")
        availableLanguage.append("ru")
        availableLanguage.append("en")

        tableViewCells = [.credentials, .paySBP, .tinkoffPay, .showEmail, .acquiring, .addCardCheckType, .server, .customServer, .language]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // swiftlint:disable:next function_body_length
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
        case .server:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedTabeViewCell.nibName) as? SegmentedTabeViewCell {
                cell.segmentedControl.removeAllSegments()
                for (index, type) in availableServers.enumerated() {
                    cell.segmentedControl.insertSegment(withTitle: type.description, at: index, animated: false)
                    if AppSetting.shared.serverType.description == type.description {
                        cell.segmentedControl.selectedSegmentIndex = index
                    }
                }

                cell.onSegmentedChanged = { [weak self] index in
                    if let value = self?.availableServers[index] {
                        switch value {
                        case .custom:
                            let customServer = self?.getCustomServerFromField() ?? ""
                            AppSetting.shared.serverType = .custom(customServer)
                        default:
                            AppSetting.shared.serverType = value
                        }
                    }
                }

                return cell
            }
        case .customServer:
            if let cell = tableView.dequeueReusableCell(withIdentifier: VerticalEditableTableCell.reusableId)
                as? VerticalEditableTableCell {
                let model = VerticalEditableView.Model(
                    labelText: "",
                    textFieldText: AppSetting.shared.customServer ?? ""
                )
                cell.configure(model: model)
                cell.apply(style: .basic)
                cell.innerView.textField.placeholder = "Fill me"
                cell.innerView.textField.removeTarget(nil, action: nil, for: .allEvents)
                cell.innerView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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

        case .credentials:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.reusableId)
                as? ButtonTableCell {
                cell.configure(
                    model: JustButton.Model(
                        id: 0,
                        title: Loc.Credentials.Settings.changeCreds,
                        image: Asset.Icons.editing.image
                            .resizeImageVerticallyIfNeeded(fitSize: CGSize(width: 40, height: 40))
                            .addInsetsInside(inset: 5),
                        onTap: { [weak self] in
                            self?.pushSdkCredentialsVC()
                        }
                    )
                )

                cell.apply(style: JustButton.Style(insets: UIEdgeInsets(side: 10), textColor: .systemBlue))
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
        case .server:
            return Loc.Title.chooseServer
        case .customServer:
            return Loc.Title.customServer
        case .language:
            return Loc.Title.paymentFormLanguage
        case .credentials:
            return Loc.Credentials.Settings.header
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
        case .server:
            return Loc.Text.chooseServerDescription
        case .customServer:
            return Loc.Text.customServerDescription
        case .language:
            return Loc.Text.Language.description
        case .credentials:
            return nil
        }
    }

    private func getCustomServerFromField() -> String {
        if let customServerIndex = tableViewCells.firstIndex(where: { $0 == .customServer }),
           let customServerCell = tableView.cellForRow(at: IndexPath(row: 0, section: customServerIndex)) as? VerticalEditableTableCell {

            let currentCustomServer = customServerCell.innerView.getTextFieldText()
            return currentCustomServer
        } else {
            return ""
        }
    }
}

// MARK: - Actions

extension SettingsTableViewController {
    @objc private func textFieldDidChange(_ sender: UITextField) {
        let customServer = getCustomServerFromField()
        AppSetting.shared.customServer = customServer

        switch AppSetting.shared.serverType {
        case .custom:
            AppSetting.shared.serverType = .custom(customServer)
        default:
            break
        }
    }
}
