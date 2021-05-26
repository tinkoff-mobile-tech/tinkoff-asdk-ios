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

final class SBPUrlPaymentViewController: UIViewController, PullableContainerScrollableContent, CustomViewLoadable {
    typealias CustomView = SBPUrlPaymentView
    
    var scrollView: UIScrollView {
        banksListViewController.scrollView
    }
    
    var contentHeight: CGFloat {
        isLoading ? loadingViewController.contentHeight : banksListViewController.contentHeight
    }
    
    var noBanksAppAvailable: ((UIViewController) -> Void)?
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    private let sbpBanksService: SBPBanksService
    private let sbpApplicationService: SBPApplicationOpener
    private let sbpPaymentService: SBPPaymentService
    private let paymentSource: PaymentSource
    private let configuration: AcquiringViewConfiguration
    
    private let loadingViewController = LoadingViewController()
    private let banksListViewController: SBPBankListViewController
    
    private var isLoading = false {
        didSet {
            isLoading ? customView.showLoading() : customView.hideLoading()
            contentHeightDidChange?(self)
        }
    }
    private var sbpURL: URL?
    
    init(paymentSource: PaymentSource,
         sbpBanksService: SBPBanksService,
         sbpApplicationService: SBPApplicationOpener,
         sbpPaymentService: SBPPaymentService,
         banksListViewController: SBPBankListViewController,
         configuration: AcquiringViewConfiguration) {
        self.paymentSource = paymentSource
        self.sbpBanksService = sbpBanksService
        self.sbpApplicationService = sbpApplicationService
        self.sbpPaymentService = sbpPaymentService
        self.banksListViewController = banksListViewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SBPUrlPaymentView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        start()
    }
}

private extension SBPUrlPaymentViewController {
    func setup() {
        setupContent()
        banksListViewController.delegate = self
    }
    
    func setupContent() {
        addChild(loadingViewController)
        customView.placeLoadingView(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        
        addChild(banksListViewController)
        customView.placeContentView(banksListViewController.view)
        banksListViewController.didMove(toParent: self)
    }
    
    func start() {
        isLoading = true
        
        sbpPaymentService.createSBPUrl(paymentSource: paymentSource) { [weak self] result in
            self?.handleSPBUrlCreation(result: result)
        }
    }
    
    func handleSPBUrlCreation(result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            DispatchQueue.main.async {
                self.sbpURL = url
            }
            loadBanks()
        case let .failure(error):
            handleError(error)
        }
    }
    
    func handleBanksLoaded(banks: [SBPBank]) {
        let result = sbpBanksService.checkBankAvailabilityAndHandleTinkoff(banks: banks)
        
        guard !result.banks.isEmpty else {
            noBanksAppAvailable?(self)
            return
        }

        guard result.banks.count > 1 else {
            openBankApplication(bank: result.banks[0])
            return
        }
                
        banksListViewController.banks = result.banks
        banksListViewController.selectedIndex = result.selectedIndex
        isLoading = false
    }
    
    func handleError(_ error: Error) {
        let alertTitle = AcqLoc.instance.localize("SBP.Error.Title")
        let alertDescription = AcqLoc.instance.localize("SBP.Error.Description")
        
        showAlert(title: alertTitle,
                  description: alertDescription)
    }
    
    func loadBanks() {
        sbpBanksService.loadBanks { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(banks):
                    self.handleBanksLoaded(banks: banks)
                case let .failure(error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func openBankApplication(bank: SBPBank) {
        guard let url = self.sbpURL else {
            return
        }
        
        do {
            try sbpApplicationService.openSBPUrl(url, in: bank, completion: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
        } catch {
            showAlert(title: AcqLoc.instance.localize("SBP.OpenApplication.Error"),
                      description: nil)
        }
    }
    
    func showAlert(title: String,
                   description: String?) {
        dismiss(animated: true) { [configuration, presentingViewController] in
            guard let presentingViewController = presentingViewController else { return }
            if let alert = configuration.alertViewHelper?.presentAlertView(title,
                                                                           message: description,
                                                                           dismissCompletion: nil) {
                    presentingViewController.present(alert, animated: true, completion: nil)
            } else {
                AcquiringAlertViewController.create().present(on: presentingViewController, title: title)
            }
        }
    }
}

extension SBPUrlPaymentViewController: SBPBankListViewControllerDelegate {
    func bankListViewController(_ bankListViewController: SBPBankListViewController, didSelectBank bank: SBPBank) {
        openBankApplication(bank: bank)
    }
}
