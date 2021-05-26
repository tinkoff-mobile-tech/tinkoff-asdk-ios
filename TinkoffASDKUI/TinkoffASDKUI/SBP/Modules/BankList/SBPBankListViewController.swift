//
//
//  SBPBankListViewController.swift
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
import TinkoffASDKCore

protocol SBPBankListViewControllerDelegate: AnyObject {
    func bankListViewController(_ bankListViewController: SBPBankListViewController,
                                didSelectBank bank: SBPBank)
}

final class SBPBankListViewController: UIViewController, PullableContainerScrollableContent, CustomViewLoadable {
    typealias CustomView = SBPBankListView

    weak var delegate: SBPBankListViewControllerDelegate?
    
    var scrollView: UIScrollView {
        customView.tableView
    }
    
    var contentHeight: CGFloat {
        customView.tableView.contentSize.height + customView.continueButtonContainer.bounds.height
    }
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    var banks: [SBPBank] {
        get {
            tableManager.banks
        }
        set {
            tableManager.banks = newValue
        }
    }
    
    var selectedIndex: Int? {
        get {
            tableManager.selectedIndex
        }
        set {
            tableManager.selectedIndex = newValue
            customView.continueButton.isEnabled = customView.tableView.indexPathForSelectedRow != nil
        }
    }
    
    private let style: SBPBankListView.Style
    private let tableManager: SBPBankListTableManager
    
    // MARK: - Init

    init(style: SBPBankListView.Style,
         tableManager: SBPBankListTableManager) {
        self.style = style
        self.tableManager = tableManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = SBPBankListView(style: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentHeightDidChange?(self)
    }
}

private extension SBPBankListViewController {
    func setup() {
        customView.headerView.titleLabel.text = AcqLoc.instance.localize(
            "SBP.BanksList.Header.Title"
        )
        customView.headerView.subtitleLabel.text = AcqLoc.instance.localize(
            "SBP.BanksList.Header.Subtitle"
        )
        customView.continueButton.setTitle(AcqLoc.instance.localize(
            "SBP.BanksList.Button.Title"
        ), for: .normal)
        
        customView.continueButton.isEnabled = customView.tableView.indexPathForSelectedRow != nil
        customView.continueButton.addTarget(self,
                                            action: #selector(didTapContinueButton),
                                            for: .touchUpInside)
        
        tableManager.setTableView(customView.tableView)
        tableManager.rowSelection = { [weak self] index in
            self?.customView.continueButton.isEnabled = true
        }
    }
    
    @objc func didTapContinueButton() {
        guard let selectedIndex = customView.tableView.indexPathForSelectedRow else {
            return
        }
        let bank = banks[selectedIndex.row]
        delegate?.bankListViewController(self, didSelectBank: bank)
    }
}
