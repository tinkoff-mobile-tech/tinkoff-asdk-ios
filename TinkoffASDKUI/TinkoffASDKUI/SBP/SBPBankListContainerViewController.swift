//
//
//  SBPBankListContainerViewController.swift
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

public final class SBPBankListContainerViewController: UIViewController, PullableContainerScrollableContent {
    public var scrollView: UIScrollView {
        banksListViewController.scrollView
    }
    
    public var contentHeight: CGFloat {
        isLoading ? loadingViewController.contentHeight : banksListViewController.contentHeight
    }
    
    public var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    private let sbpBanksService: SBPBanksService
    private let style: Style
    
    private let loadingViewController = LoadingViewController()
    private lazy var banksListViewController = SBPBankListViewController(
        style: .init(continueButtonStyle: style.bigButtonStyle)
    )
    
    private var isLoading = false
    
    public init(sbpBanksService: SBPBanksService,
                style: Style) {
        self.sbpBanksService = sbpBanksService
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadBanks()
    }
}

private extension SBPBankListContainerViewController {
    func setup() {
        showBanksList()
    }
    
    func loadBanks() {
        isLoading = true
        showLoading()
        sbpBanksService.loadBanks { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case let .success(banks):
                self.banksListViewController.banks = banks
                self.hideLoading()
                self.contentHeightDidChange?(self)
            case .failure:
                break
            }
        }
    }
    
    func showLoading() {
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        
        loadingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        contentHeightDidChange?(self)
    }
    
    func hideLoading() {
        loadingViewController.willMove(toParent: nil)
        loadingViewController.view.removeFromSuperview()
        loadingViewController.didMove(toParent: nil)
    }
    
    func showBanksList() {
        addChild(banksListViewController)
        view.addSubview(banksListViewController.view)
        banksListViewController.didMove(toParent: self)
        
        banksListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banksListViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            banksListViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            banksListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            banksListViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func showError() {
        
    }
}
 
