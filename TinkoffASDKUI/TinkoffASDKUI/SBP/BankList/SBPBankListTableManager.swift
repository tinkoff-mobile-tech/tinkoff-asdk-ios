//
//
//  SBPBankListTableManager.swift
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


import TinkoffASDKCore

final class SBPBankListTableManager: NSObject {
    
    var rowSelection: ((Int) -> Void)?
    
    private let tableView: UITableView
    
    var banks = [SBPBank]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setup()
    }
}

private extension SBPBankListTableManager {
    func setup() {
        tableView.register(SBPBankCell.self, forCellReuseIdentifier: String(describing: SBPBankCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

extension SBPBankListTableManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        banks.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let bankCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SBPBankCell.self),
                                                           for: indexPath) as? SBPBankCell else {
            return UITableViewCell()
        }
        
        let bank = banks[indexPath.row]
        bankCell.bankTitleLabel.text = bank.name
        
        return bankCell
    }
}

extension SBPBankListTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        rowSelection?(indexPath.row)
    }
}
