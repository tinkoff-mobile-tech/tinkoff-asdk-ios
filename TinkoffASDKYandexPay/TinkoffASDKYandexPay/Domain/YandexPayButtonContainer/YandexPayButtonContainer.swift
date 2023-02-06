//
//  YandexPayButtonContainer.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 01.12.2022.
//

import TinkoffASDKCore
import TinkoffASDKUI
import UIKit
import YandexPaySDK

final class YandexPayButtonContainer: UIView {
    // MARK: Dependencies

    private var configuration: YandexPayButtonContainerConfiguration
    private let sdkButtonFactory: IYandexPaySDKButtonFactory
    private let paymentSheetFactory: IYPPaymentSheetFactory
    private let yandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly
    private weak var delegate: YandexPayButtonContainerDelegate?

    // MARK: Lazy Dependencies

    private lazy var yandexPayButton: YandexPayButton = sdkButtonFactory.createButton(
        configuration: .from(configuration),
        asyncDelegate: self
    )

    private lazy var yandexPayPaymentFlow = yandexPayPaymentFlowAssembly.yandexPayPaymentFlow(delegate: self)

    // MARK: Init

    init(
        configuration: YandexPayButtonContainerConfiguration,
        sdkButtonFactory: IYandexPaySDKButtonFactory,
        paymentSheetFactory: IYPPaymentSheetFactory,
        yandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly,
        delegate: YandexPayButtonContainerDelegate
    ) {
        self.configuration = configuration
        self.sdkButtonFactory = sdkButtonFactory
        self.paymentSheetFactory = paymentSheetFactory
        self.yandexPayPaymentFlowAssembly = yandexPayPaymentFlowAssembly
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(yandexPayButton)
        yandexPayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yandexPayButton.topAnchor.constraint(equalTo: topAnchor),
            yandexPayButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            yandexPayButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            yandexPayButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // У оригинальной кнопки `YandexPay` есть дефолтное скругление.
        // Здесь устанавливается дефолтное скругление для контейнера и обнуляется у кнопки.
        // Таким образом можно будет управлять layer-ом контейнера из клиентского кода
        clipsToBounds = true
        layer.cornerRadius = yandexPayButton.layer.cornerRadius
        yandexPayButton.layer.cornerRadius = .zero
    }
}

// MARK: - IYandexPayButtonContainer

extension YandexPayButtonContainer: IYandexPayButtonContainer {
    var theme: YandexPayButtonContainerTheme {
        configuration.theme
    }

    func setLoaderVisible(_ visible: Bool, animated: Bool) {
        yandexPayButton.setLoaderVisible(visible, animated: animated)
    }

    func reloadPersonalizationData(completion: @escaping (Error?) -> Void) {
        yandexPayButton.reloadPersonalizationData(completion: completion)
    }

    func setTheme(_ theme: YandexPayButtonContainerTheme, animated: Bool) {
        configuration.theme = theme
        yandexPayButton.setTheme(.from(theme), animated: animated)
    }
}

// MARK: - YandexPayButtonAsyncDelegate

extension YandexPayButtonContainer: YandexPayButtonAsyncDelegate {
    private enum Failure: Error {
        case unknown
    }

    func yandexPayButtonDidRequestViewControllerForPresentation(_ button: YandexPayButton) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayButtonDidRequestPaymentSheet(_ button: YandexPayButton, completion: @escaping (YPPaymentSheet?) -> Void) {
        let completion = { [paymentSheetFactory] (paymentSheet: YandexPayPaymentSheet?) in
            let yandexPayPaymentSheet = paymentSheet.map(paymentSheetFactory.create(with:))
            completion(yandexPayPaymentSheet)
        }

        delegate?.yandexPayButtonContainer(self, didRequestPaymentSheet: completion)
    }

    func yandexPayButton(_ button: YandexPayButton, didCompletePaymentWithResult result: YPPaymentResult) {
        switch result {
        case let .succeeded(paymentInfo):
            let completion = { [weak self] (flow: PaymentFlow?) in
                guard let self = self, let flow = flow else { return }
                DispatchQueue.performOnMain {
                    self.yandexPayPaymentFlow.start(with: flow, base64Token: paymentInfo.paymentToken)
                }
            }
            delegate?.yandexPayButtonContainer(self, didRequestPaymentFlow: completion)
        case .cancelled:
            delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: .cancelled(nil))
        case let .failed(error):
            delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: .failed(error))
        @unknown default:
            delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: .failed(Failure.unknown))
        }
    }
}

// MARK: - YandexPayPaymentFlowDelegate

extension YandexPayButtonContainer: YandexPayPaymentFlowDelegate {
    func yandexPayPaymentFlowDidRequestViewControllerForPresentation(_ flow: IYandexPayPaymentFlow) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: PaymentResult) {
        delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: result)
    }
}
