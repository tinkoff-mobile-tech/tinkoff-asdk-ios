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

public enum SBPUrlPaymentViewControllerError: Error {
    case failedToOpenBankApp(SBPBank)
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
    
    private let paymentService: PaymentService
    private let sbpBanksService: SBPBanksService
    private let sbpApplicationService: SBPApplicationOpener
    private let sbpPaymentService: SBPPaymentService
    private let paymentSource: PaymentSource
    private let configuration: AcquiringViewConfiguration
    private let completion: PaymentCompletionHandler?
    
    private let loadingViewController = LoadingViewController()
    private let banksListViewController: SBPBankListViewController
    
    private var isLoading = false {
        didSet {
            isLoading ? customView.showLoading() : customView.hideLoading()
            contentHeightDidChange?(self)
        }
    }
    private var sbpURL: URL?
    private var paymentStatusResponse: PaymentStatusResponse?
    
    init(paymentSource: PaymentSource,
         paymentService: PaymentService,
         sbpBanksService: SBPBanksService,
         sbpApplicationService: SBPApplicationOpener,
         sbpPaymentService: SBPPaymentService,
         banksListViewController: SBPBankListViewController,
         configuration: AcquiringViewConfiguration,
         completion: PaymentCompletionHandler?) {
        self.paymentSource = paymentSource
        self.paymentService = paymentService
        self.sbpBanksService = sbpBanksService
        self.sbpApplicationService = sbpApplicationService
        self.sbpPaymentService = sbpPaymentService
        self.banksListViewController = banksListViewController
        self.configuration = configuration
        self.completion = completion
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
    
    func wasClosed() {
        let response = PaymentStatusResponse(success: false,
                                             errorCode: 0,
                                             errorMessage: nil,
                                             orderId: paymentStatusResponse?.orderId ?? "",
                                             paymentId: paymentStatusResponse?.paymentId ?? 0,
                                             amount: paymentStatusResponse?.amount.int64Value ?? 0,
                                             status: .cancelled)
        completion?(.success(response))
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
        
        switch paymentSource {
        case let .paymentId(paymentId):
            paymentService.getPaymentStatus(paymentId: paymentId) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.handleError(error)
                case let .success(response):
                    self?.paymentStatusResponse = response
                    self?.createSPBUrl(paymentId: paymentId)
                }
            }
        case let .paymentData(initData):
            paymentService.initPaymentWith(paymentData: initData) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.handleError(error)
                case let .success(response):
                    self?.paymentStatusResponse = .init(success: true,
                                                        errorCode: 0,
                                                        errorMessage: nil,
                                                        orderId: response.orderId,
                                                        paymentId: response.paymentId,
                                                        amount: response.amount,
                                                        status: .new)
                    self?.createSPBUrl(paymentId: response.paymentId)
                }
            }
        }
    }
    
    func createSPBUrl(paymentId: Int64) {
        sbpPaymentService.createSBPUrl(paymentId: paymentId) { [weak self] result in
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
            DispatchQueue.main.async {
                self.handleError(error)
            }
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
        DispatchQueue.main.async {
            let alertTitle = AcqLoc.instance.localize("SBP.Error.Title")
            let alertDescription = AcqLoc.instance.localize("SBP.Error.Description")
            
            self.showAlert(title: alertTitle,
                           description: alertDescription,
                           error: error)
        }
    }
    
    func loadBanks() {
        sbpBanksService.loadBanks { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(banks):
                    DispatchQueue.main.async {
                        self.handleBanksLoaded(banks: banks)
                    }
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
                if let paymentStatus = self?.paymentStatusResponse {
                    self?.completion?(.success(paymentStatus))
                }
            })
        } catch {
            showAlert(title: AcqLoc.instance.localize("SBP.OpenApplication.Error"),
                      description: nil,
                      error: SBPUrlPaymentViewControllerError.failedToOpenBankApp(bank))
        }
    }
    
    func showAlert(title: String,
                   description: String?,
                   error: Error) {
        dismiss(animated: true) { [weak self, configuration, presentingViewController] in
            guard let presentingViewController = presentingViewController else { return }
            if let alert = configuration.alertViewHelper?.presentAlertView(title,
                                                                           message: description,
                                                                           dismissCompletion: nil) {
                presentingViewController.present(alert, animated: true, completion: nil)
            } else {
                AcquiringAlertViewController.create().present(on: presentingViewController, title: title)
            }
            self?.completion?(.failure(error))
        }
    }
}

extension SBPUrlPaymentViewController: SBPBankListViewControllerDelegate {
    func bankListViewController(_ bankListViewController: SBPBankListViewController, didSelectBank bank: SBPBank) {
        openBankApplication(bank: bank)
    }
}
