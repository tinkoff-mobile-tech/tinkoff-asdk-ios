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
    private let controllerFactory: IYandexPayButtonContainerControllerFactory
    private weak var delegate: YandexPayButtonContainerDelegate?

    // MARK: Lazy Dependencies

    private lazy var yandexPayButton: YandexPayButton = sdkButtonFactory.createButton(
        configuration: .from(configuration),
        asyncDelegate: self
    )

    private lazy var controller: IYandexPayButtonContainerController = controllerFactory.create(with: self)

    // MARK: Init

    init(
        configuration: YandexPayButtonContainerConfiguration,
        sdkButtonFactory: IYandexPaySDKButtonFactory,
        controllerFactory: IYandexPayButtonContainerControllerFactory,
        delegate: YandexPayButtonContainerDelegate
    ) {
        self.configuration = configuration
        self.sdkButtonFactory = sdkButtonFactory
        self.controllerFactory = controllerFactory
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
        // Таким образом можно будет управлять стилем контейнера из клиентского кода
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
    func yandexPayButtonDidRequestViewControllerForPresentation(_ button: YandexPayButton) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayButtonDidRequestPaymentSheet(
        _ button: YandexPayButton,
        completion: @escaping (YPPaymentSheet?) -> Void
    ) {
        controller.requestPaymentSheet(completion: completion)
    }

    func yandexPayButton(
        _ button: YandexPayButton,
        didCompletePaymentWithResult result: YPPaymentResult
    ) {
        controller.handlePaymentResult(result)
    }
}

// MARK: - YandexPayButtonContainerControllerDelegate

extension YandexPayButtonContainer: YandexPayButtonContainerControllerDelegate {
    func yandexPayController(
        _ controller: IYandexPayButtonContainerController,
        didRequestPaymentSheet completion: @escaping (YandexPayPaymentSheet?) -> Void
    ) {
        delegate?.yandexPayButtonContainer(self, didRequestPaymentSheet: completion)
    }

    func yandexPayControllerDidRequestViewControllerForPresentation(
        _ controller: IYandexPayButtonContainerController
    ) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayController(
        _ controller: YandexPayButtonContainerController,
        didCompleteWithResult result: YandexPayPaymentResult
    ) {
        delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: result)
    }
}
