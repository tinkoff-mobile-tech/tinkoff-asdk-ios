//
//  TinkoffPayPaymentViewController.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 15.04.2022.
//

import UIKit
import TinkoffASDKCore

final class TinkoffPayPaymentViewController: UIViewController, PaymentPollingContent {
    var didStartLoading: ((String) -> Void)?
    var didStopLoading: (() -> Void)?
    var didUpdatePaymentStatusResponse: ((PaymentStatusResponse) -> Void)?
    var paymentStatusResponse: (() -> PaymentStatusResponse?)?
    var showAlert: ((String, String?, Error) -> Void)?
    var didStartPayment: (() -> Void)?
    
    var scrollView: UIScrollView { UIScrollView() }
    
    var contentHeight: CGFloat { 0 }
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    private let acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration
    private let paymentService: PaymentService
    private let tinkoffPayController: TinkoffPayController
    private let tinkoffPayVersion: GetTinkoffPayStatusResponse.Status.Version
    private let application: UIApplication
    
    init(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
         paymentService: PaymentService,
         tinkoffPayController: TinkoffPayController,
         tinkoffPayVersion: GetTinkoffPayStatusResponse.Status.Version,
         application: UIApplication) {
        self.acquiringPaymentStageConfiguration = acquiringPaymentStageConfiguration
        self.paymentService = paymentService
        self.tinkoffPayController = tinkoffPayController
        self.tinkoffPayVersion = tinkoffPayVersion
        self.application = application
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

private extension TinkoffPayPaymentViewController {
    func setup() {}
    
    func start() {
        didStartLoading?("")
        
        switch acquiringPaymentStageConfiguration.paymentStage {
        case let .finish(paymentId):
            paymentService.getPaymentStatus(paymentId: paymentId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    self.handleError(error)
                case let .success(response):
                    self.didUpdatePaymentStatusResponse?(response)
                    self.performTinkoffPayWith(paymentId: response.paymentId,
                                               version: self.tinkoffPayVersion)
                }
            }
        case let .`init`(paymentData):
            var tinkoffPayPaymentData = paymentData
            tinkoffPayPaymentData.addPaymentData(["TinkoffPayWeb": "true"])
            paymentService.initPaymentWith(paymentData: tinkoffPayPaymentData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    self.handleError(error)
                case let .success(response):
                    let statusResponse: PaymentStatusResponse = .init(success: true,
                                                                      errorCode: 0,
                                                                      errorMessage: nil,
                                                                      orderId: response.orderId,
                                                                      paymentId: response.paymentId,
                                                                      amount: response.amount,
                                                                      status: .new)
                    self.didUpdatePaymentStatusResponse?(statusResponse)
                    self.performTinkoffPayWith(paymentId: response.paymentId,
                                               version: self.tinkoffPayVersion)
                }
            }
        }
    }
    
    func performTinkoffPayWith(paymentId: Int64,
                               version: GetTinkoffPayStatusResponse.Status.Version) {
        _ = tinkoffPayController.getTinkoffPayLink(paymentId: paymentId,
                                                   version: version,
                                                   completion: { [weak self] result in
            switch result {
            case let .success(url):
                self?.openTinkoffPayDeeplink(url: url)
            case let .failure(error):
                self?.handleError(error)
            }
        })
    }
    
    func openTinkoffPayDeeplink(url: URL) {
        didStartLoading?(AcqLoc.instance.localize("TP.LoadingStatus.Title"))
        guard application.canOpenURL(url) else {
            // TODO: Alert if needed
            return
        }
        application.open(url)
    }
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            let alertTitle = AcqLoc.instance.localize("TP.Error.Title")
            let alertDescription = AcqLoc.instance.localize("TP.Error.Description")
            
            self.showAlert?(alertTitle, alertDescription, error)
        }
    }
}

