//
//  PaymentPollingViewController.swift
//  TinkoffASDKUI
//
//  Created by Serebryaniy Grigoriy on 15.04.2022.
//

import UIKit
import TinkoffASDKCore

public enum PaymentPollingError: Swift.Error {
    /// Превышен лимит запросов статуса платежа
    case requestLimitExceeded
}

protocol PaymentPollingContent: UIViewController & PullableContainerScrollableContent {
    var didStartLoading: ((String) -> Void)? { get set}
    var didStopLoading: (() -> Void)? { get set}
    var didUpdatePaymentStatusResponse: ((PaymentStatusResponse) -> Void)? { get set }
    var paymentStatusResponse: (() -> PaymentStatusResponse?)? { get set }
    var showAlert: ((_ title: String, _ description: String?, _ error: Error) -> Void)? { get set }
    var didStartPayment: (() -> Void)? { get set }
}

final class PaymentPollingViewController<ContentViewController: PaymentPollingContent>: UIViewController, PullableContainerScrollableContent, CustomViewLoadable {
    
    var scrollView: UIScrollView { contentViewController.scrollView }
    
    var contentHeight: CGFloat {
        isLoading ? loadingViewController.contentHeight : contentViewController.contentHeight
    }
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    typealias CustomView = PaymentPollingView
    
    private let paymentService: PaymentService
    private let completion: PaymentCompletionHandler?
    private let configuration: AcquiringViewConfiguration
    
    private let loadingViewController = LoadingViewController()
    private let contentViewController: ContentViewController
    
    private var isLoading = false {
        didSet {
            isLoading ? customView.showLoading() : customView.hideLoading()
            contentHeightDidChange?(self)
        }
    }
    
    private var paymentStatusResponse: PaymentStatusResponse?
    private var isPollingPaymentStatus = false
    private var didStartPayment = false
    private var errorPaymentStatusRequestCount = Int.paymentStatusRequestLimit
    private var paymentStatusRequestCount = Int.paymentStatusRequestLimit
    
    init(contentViewController: ContentViewController,
         paymentService: PaymentService,
         configuration: AcquiringViewConfiguration,
         completion: PaymentCompletionHandler?) {
        self.contentViewController = contentViewController
        self.paymentService = paymentService
        self.configuration = configuration
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleActiveState),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    override func loadView() {
        view = PaymentPollingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func wasClosed() {
        isPollingPaymentStatus = false
        completion?(.success(cancelledResponse))
    }
    
    @objc private func handleActiveState() {
        if !isPollingPaymentStatus, didStartPayment, let paymentId = paymentStatusResponse?.paymentId {
            startPaymentStatusPolling(paymentId: paymentId)
        }
    }
}

private extension PaymentPollingViewController {
    func setup() {
        contentViewController.didStartLoading = { [weak self] statusText in
            self?.loadingViewController.configure(with: statusText)
            self?.isLoading = true
        }
        
        contentViewController.didStopLoading = { [weak self] in
            self?.isLoading = false
        }
        
        contentViewController.didUpdatePaymentStatusResponse = { [weak self] paymentStatusResponse in
            self?.paymentStatusResponse = paymentStatusResponse
        }
        
        contentViewController.paymentStatusResponse = { [weak self] in
            return self?.paymentStatusResponse
        }
        
        contentViewController.showAlert = { [weak self] title, description, error in
            self?.showAlert(title: title, description: description, error: error)
        }
        
        contentViewController.didStartPayment = { [weak self] in
            self?.didStartPayment = true
        }
        
        setupContent()
    }
    
    func setupContent() {
        addChild(loadingViewController)
        customView.placeLoadingView(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        
        addChild(contentViewController)
        customView.placeContentView(contentViewController.view)
        contentViewController.didMove(toParent: self)
    }
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            let alertTitle = L10n.Sbp.Error.title
            let alertDescription = L10n.Sbp.Error.description
            self.showAlert(title: alertTitle,
                           description: alertDescription,
                           error: error)
        }
    }
    
    func showAlert(title: String,
                   description: String?,
                   error: Error) {
        let dismissClosure: (() -> Void)? = { [weak self] in
            self?.completion?(.failure(error))
        }
        if let alert = configuration.alertViewHelper?.presentAlertView(title,
                                                                       message: description,
                                                                       dismissCompletion: dismissClosure) {
            self.present(alert, animated: true, completion: nil)
        } else {
            AcquiringAlertViewController.create().present(on: self,
                                                          title: title,
                                                          dismissClosure: dismissClosure)
        }
    }
    
    func startPaymentStatusPolling(paymentId: Int64) {
        isPollingPaymentStatus = true
        paymentService.getPaymentStatus(paymentId: paymentId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    guard self.errorPaymentStatusRequestCount > 0 else {
                        self.isPollingPaymentStatus = false
                        self.handleError(error)
                        return
                    }
                    self.errorPaymentStatusRequestCount -= 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + .paymentStatusPollingInterval) { [weak self] in
                        self?.startPaymentStatusPolling(paymentId: paymentId)
                    }
                case let .success(response):
                    self.errorPaymentStatusRequestCount = .paymentStatusRequestLimit
                    self.paymentStatusRequestCount -= 1
                    switch response.status {
                    case .new, .unknown, .formShowed:
                        guard self.paymentStatusRequestCount > 0 else {
                            self.isPollingPaymentStatus = false
                            self.completion?(.failure(PaymentPollingError.requestLimitExceeded))
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .paymentStatusPollingInterval) { [weak self] in
                            self?.startPaymentStatusPolling(paymentId: paymentId)
                        }
                    default:
                        self.isPollingPaymentStatus = false
                        self.completion?(.success(response))
                    }
                }
            }
        }
    }
    
    var cancelledResponse: PaymentStatusResponse {
        PaymentStatusResponse(success: false,
                              errorCode: 0,
                              errorMessage: nil,
                              orderId: paymentStatusResponse?.orderId ?? "",
                              paymentId: paymentStatusResponse?.paymentId ?? 0,
                              amount: paymentStatusResponse?.amount.int64Value ?? 0,
                              status: .cancelled)
    }
}

private extension Int {
    static let paymentStatusRequestLimit = 5
}

private extension TimeInterval {
    static let paymentStatusPollingInterval: TimeInterval = 5
}
