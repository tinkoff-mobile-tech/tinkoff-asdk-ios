//
//
//  EditSdkCredentialsViewController.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

final class EditSdkCredentialsViewController: UIViewController {

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Loc.Credentials.Viewcontroller.title
        setupViews()
        tableView.reloadData()
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        setupTableView()
    }

    private func setupTableView() {
        tableView.makeEqualToSuperviewToSafeArea()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = UIConstants.tableViewBottomInset

        tableView.register(CredentialsTableCell.self, forCellReuseIdentifier: CredentialsTableCell.reusableId)
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.reusableId)
    }

    private func addSdkCredsTemplateCell() {
        var newList = AppSetting.shared.listOfSdkCredentials
        let fillMe = "Fill me"
        let newsCreds = SdkCredentials(
            uuid: UUID().uuidString,
            name: fillMe,
            description: fillMe,
            publicKey: StageTestData.testPublicKey, // предзаполняем, валиден для всех
            terminalKey: fillMe,
            terminalPassword: fillMe,
            customerKey: fillMe
        )
        newList.append(newsCreds)
        AppSetting.shared.listOfSdkCredentials = newList

        tableView.reloadData()
    }
}

extension EditSdkCredentialsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            guard let cell = (
                tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.reusableId)
                    ?? tableView.defaultCell()
            ) as? ButtonTableCell

            else {
                return tableView.defaultCell()
            }

            cell.configure(
                model: JustButton.Model(
                    id: 0,
                    title: Loc.Credentials.Buttons.add,
                    image: Asset.Icons.add.image
                        .resizeImageVerticallyIfNeeded(
                            fitSize: UIConstants.addButtonSize
                        )
                        .addInsetsInside(inset: UIConstants.addButtonImageInset),
                    onTap: { [weak self] in
                        self?.addSdkCredsTemplateCell()
                    }
                )
            )

            cell.apply(style: JustButton.Style(insets: UIConstants.addButtonInsets))

            return cell

        case 1 ... AppSetting.shared.listOfSdkCredentials.count + 1:
            let index = indexPath.row - 1

            guard let cell = (
                tableView.dequeueReusableCell(withIdentifier: CredentialsTableCell.reusableId)
                    ?? tableView.defaultCell()
            ) as? CredentialsTableCell

            else {
                return tableView.defaultCell()
            }

            let creds = AppSetting.shared.listOfSdkCredentials[index]
            let isOn = AppSetting.shared.activeSdkCredentials == creds

            cell.configure(
                model:
                CredentialsView.Model(
                    creds: creds,
                    name: creds.name,
                    description: creds.description,
                    isActiveSwitchModel: HorizontalTitleSwitchView.Model(
                        isOn: isOn,
                        isEnabled: !isOn,
                        text: Loc.Credentials.Buttons.active,
                        onSwitch: { [weak self] value in
                            self?.onSwitch(credsUuid: creds.uuid, isOn: value)
                        }
                    ),
                    shouldShowDeleteButton: !isOn,
                    viewOutput: self
                )
            )

            return cell

        default:
            return tableView.defaultCell()
        }
    }
}

// MARK: - EditSdkCredentialsViewController + UITableViewDataSource

extension EditSdkCredentialsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSetting.shared.listOfSdkCredentials.count + 1
    }
}

// MARK: - EditSdkCredentialsViewController + CredentialsViewOutput

extension EditSdkCredentialsViewController: CredentialsViewOutput {

    func onEditing(credentialsViewInput: CredentialsViewInput) {}

    func onSaveAfterEdit(
        credentialsViewInput: CredentialsViewInput,
        newCreds: SdkCredentials,
        credsUuid: String
    ) {
        var credsList = AppSetting.shared.listOfSdkCredentials
        guard let index = credsList.firstIndex(where: { $0.uuid == credsUuid }) else {
            return
        }

        credsList[index] = newCreds
        if AppSetting.shared.activeSdkCredentials.uuid == credsUuid {
            AppSetting.shared.activeSdkCredentials = newCreds
        }
        AppSetting.shared.listOfSdkCredentials = credsList
        tableView.reloadData()
    }

    func onDelete(credentialsViewInput: CredentialsViewInput, credsUuid: String) {
        var list = AppSetting.shared.listOfSdkCredentials
        list.removeAll { creds in
            creds.uuid == credsUuid
        }

        AppSetting.shared.listOfSdkCredentials = list
        tableView.reloadData()
    }

    func onSwitch(credsUuid: String, isOn: Bool) {
        guard isOn else { return }
        guard let currentActiveCreds = AppSetting
            .shared
            .listOfSdkCredentials
            .first(where: { $0.uuid == credsUuid })
        else {
            return
        }

        AppSetting.shared.activeSdkCredentials = currentActiveCreds
        tableView.reloadData()
    }
}

private enum UIConstants {
    static let addButtonSize = CGSize(width: 30, height: 30)
    static let addButtonImageInset: UInt = 5
    static let addButtonInsets = UIEdgeInsets(side: 10)
    static let tableViewBottomInset: CGFloat = 420
}
