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

public enum SBPPaymentError: Error {
    case failedToOpenBankApp(SBPBank)
}

final class SBPBankListViewController: UIViewController, PaymentPollingContent, CustomViewLoadable {
    
    var didStartLoading: ((String) -> Void)?
    var didStopLoading: (() -> Void)?
    var didUpdatePaymentStatusResponse: ((PaymentStatusResponse) -> Void)?
    var noBanksAppAvailable: ((UIViewController, PaymentStatusResponse) -> Void)?
    var paymentStatusResponse: (() -> PaymentStatusResponse?)?
    var showAlert: ((String, String?, Error) -> Void)?
    var didStartPayment: (() -> Void)?
    
    typealias CustomView = SBPBankListView
    
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
    
    private let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
    private let paymentService: PaymentService
    private let sbpBanksService: SBPBanksService
    private let sbpApplicationService: SBPApplicationOpener
    private let sbpPaymentService: SBPPaymentService
    private let style: SBPBankListView.Style
    private let tableManager: SBPBankListTableManager
    
    private var sbpURL: URL?
    
    // MARK: - Init

    init(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
         paymentService: PaymentService,
         sbpBanksService: SBPBanksService,
         sbpApplicationService: SBPApplicationOpener,
         sbpPaymentService: SBPPaymentService,
         style: SBPBankListView.Style,
         tableManager: SBPBankListTableManager) {
        self.acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration
        self.paymentService = paymentService
        self.sbpBanksService = sbpBanksService
        self.sbpApplicationService = sbpApplicationService
        self.sbpPaymentService = sbpPaymentService
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
        start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentHeightDidChange?(self)
    }
}

private extension SBPBankListViewController {
    func setup() {
        customView.headerView.titleLabel.text = L10n.Sbp.BanksList.Header.title
        customView.headerView.subtitleLabel.text = L10n.Sbp.BanksList.Header.subtitle
        customView.continueButton.setTitle(L10n.Sbp.BanksList.Button.title, for: .normal)
        
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
        openBankApplication(bank: bank)
    }
    
    func start() {
        didStartLoading?("")
        
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .finish(paymentId):
            paymentService.getPaymentStatus(paymentId: paymentId) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.handleError(error)
                case let .success(response):
                    self?.didUpdatePaymentStatusResponse?(response)
                    self?.createSPBUrl(paymentId: paymentId)
                }
            }
        case let .`init`(paymentData):
            paymentService.initPaymentWith(paymentData: paymentData) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.handleError(error)
                case let .success(response):
                    let statusResponse: PaymentStatusResponse = .init(success: true,
                                                                      errorCode: 0,
                                                                      errorMessage: nil,
                                                                      orderId: response.orderId,
                                                                      paymentId: response.paymentId,
                                                                      amount: response.amount,
                                                                      status: .new)
                    self?.didUpdatePaymentStatusResponse?(statusResponse)
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
    
    func handleBanksLoaded(banks: [SBPBank]) {
        let result = sbpBanksService.checkBankAvailabilityAndHandleTinkoff(banks: banks)
        
        guard !result.banks.isEmpty else {
            noBanksAppAvailable?(self, cancelledResponse)
            return
        }
        
        guard result.banks.count > 1 else {
            openBankApplication(bank: result.banks[0])
            return
        }
        
        self.banks = result.banks
        selectedIndex = result.selectedIndex
        didStopLoading?()
    }
    
    func openBankApplication(bank: SBPBank) {
        guard let url = self.sbpURL else {
            return
        }
        
        do {
            try sbpApplicationService.openSBPUrl(url, in: bank, completion: { [weak self] result in
                self?.didStartPayment?()
                self?.handleBankApplicationOpen(result: result)
            })
        } catch {
            showAlert?(L10n.Sbp.OpenApplication.error,
                       nil,
                       SBPPaymentError.failedToOpenBankApp(bank))
        }
    }
    
    func handleBankApplicationOpen(result: Bool) {
        guard result else { return }
        didStartLoading?(L10n.Sbp.LoadingStatus.title)
    }
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            let alertTitle = L10n.Sbp.Error.title
            let alertDescription = L10n.Sbp.Error.description
            
            self.showAlert?(alertTitle,
                            alertDescription,
                            error)
        }
    }
    
    var cancelledResponse: PaymentStatusResponse {
        PaymentStatusResponse(success: false,
                              errorCode: 0,
                              errorMessage: nil,
                              orderId: paymentStatusResponse?()?.orderId ?? "",
                              paymentId: paymentStatusResponse?()?.paymentId ?? 0,
                              amount: paymentStatusResponse?()?.amount.int64Value ?? 0,
                              status: .cancelled)
    }
}
