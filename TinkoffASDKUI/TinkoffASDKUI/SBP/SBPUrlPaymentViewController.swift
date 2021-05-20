//
//
//  SBPUrlPaymentViewController.swift
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

public enum PaymentSource {
    case paymentData(PaymentInitData)
    case paymentId(Int64)
}

final class SBPUrlPaymentViewController: UIViewController, PullableContainerScrollableContent {
    var scrollView: UIScrollView {
        banksListViewController.scrollView
    }
    
    var contentHeight: CGFloat {
        isLoading ? loadingViewController.contentHeight : banksListViewController.contentHeight
    }
    
    var noBanksAppAvailable: ((UIViewController) -> Void)?
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    private let sbpBanksService: SBPBanksService
    private let sbpApplicationService: SBPApplicationService
    private let sbpPaymentService: SBPPaymentService
    private let paymentSource: PaymentSource
    
    private let loadingViewController = LoadingViewController()
    private let banksListViewController: SBPBankListViewController
    
    private var isLoading = false
    private var sbpURL: URL?
    
    init(paymentSource: PaymentSource,
         sbpBanksService: SBPBanksService,
         sbpApplicationService: SBPApplicationService,
         sbpPaymentService: SBPPaymentService,
         banksListViewController: SBPBankListViewController) {
        self.paymentSource = paymentSource
        self.sbpBanksService = sbpBanksService
        self.sbpApplicationService = sbpApplicationService
        self.sbpPaymentService = sbpPaymentService
        self.banksListViewController = banksListViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        start()
    }
}

private extension SBPUrlPaymentViewController {
    func setup() {
        showBanksList()
        banksListViewController.delegate = self
    }
    
    func start() {
        isLoading = true
        showLoading()
        
        sbpPaymentService.createSBPUrl(paymentSource: paymentSource) { [weak self] result in
            self?.handleSPBUrlCreation(result: result)
        }
    }
    
    func handleSPBUrlCreation(result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            sbpURL = url
            loadBanks()
        case let .failure(error):
            handleError(error)
        }
    }
    
    func handleBanksLoaded(result: LoadBanksResult) {
        let availableBanks = result.banks.filter { sbpApplicationService.canOpenBankApp(bank: $0) }
        guard !availableBanks.isEmpty else {
            noBanksAppAvailable?(self)
            return
        }
        
        guard availableBanks.count > 1 else {
            openBankApplication(bank: availableBanks[0])
            return
        }
                
        isLoading = false
        banksListViewController.banksResult = .init(banks: availableBanks,
                                                    selectedIndex: result.selectedIndex)
        contentHeightDidChange?(self)
        hideLoading()
    }
    
    func handleError(_ error: Error) {
        
    }
    
    func loadBanks() {
        sbpBanksService.loadBanks { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(result):
                    self.handleBanksLoaded(result: result)
                case let .failure(error):
                    self.handleError(error)
                }
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
    
    func openBankApplication(bank: SBPBank) {
        guard let url = self.sbpURL else {
            return
        }
        
        try? sbpApplicationService.openSBPUrl(url, in: bank, completion: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
}

extension SBPUrlPaymentViewController: SBPBankListViewControllerDelegate {
    func bankListViewController(_ bankListViewController: SBPBankListViewController, didSelectBank bank: SBPBank) {
        openBankApplication(bank: bank)
    }
}

