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
    
    private var tableView: UITableView?
    
    private let cellImageLoader: CellImageLoader
    
    var banksResult: LoadBanksResult? {
        didSet {
            tableView?.reloadData()
            guard let selectedIndex = banksResult?.selectedIndex else { return }
            tableView?.selectRow(at: IndexPath(row: selectedIndex, section: 0),
                                 animated: false,
                                 scrollPosition: .none)
        }
    }
    
    init(cellImageLoader: CellImageLoader) {
        self.cellImageLoader = cellImageLoader
        super.init()
        setup()
    }
    
    func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
        setup()
    }
}

private extension SBPBankListTableManager {
    func setup() {
        tableView?.register(SBPBankCell.self, forCellReuseIdentifier: SBPBankCell.reuseIdentifier)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.separatorStyle = .none
        tableView?.rowHeight = .rowHeight
        tableView?.estimatedRowHeight = .rowHeight
        
        cellImageLoader.setImageProcessors([SizeImageProcessor(size: CGSize(width: .cellImageSide, height: .cellImageSide),
                                                              scale: UIScreen.main.scale),
                                            RoundImageProcessor()])
    }
}

extension SBPBankListTableManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        banksResult?.banks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let banks = banksResult?.banks,
        let bankCell = tableView.dequeueReusableCell(withIdentifier: SBPBankCell.reuseIdentifier,
                                                     for: indexPath) as? SBPBankCell else {
            return UITableViewCell()
        }
        
        let bank = banks[indexPath.row]
        
        cellImageLoader.loadImage(url: bank.logoURL, cell: bankCell)
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

private extension CGFloat {
    static let rowHeight: CGFloat = 56
    static let cellImageSide: CGFloat = 40
}
