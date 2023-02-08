//
//  PayButtonPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import UIKit

final class PayButtonViewPresenter: IPayButtonViewOutput {
    // MARK: Output

    weak var output: IPayButtonViewPresenterOutput?

    // MARK: IPayButtonView Properties

    var view: IPayButtonViewInput? {
        didSet { setupView() }
    }

    // MARK: State

    var presentationState: PayButtonViewPresentationState {
        didSet {
            guard presentationState != oldValue else { return }
            setupView()
        }
    }

    private(set) var isLoading = false
    private(set) var isEnabled = true

    // MARK: Dependencies

    private let moneyFormatter: IMoneyFormatter

    // MARK: Init

    init(
        presentationState: PayButtonViewPresentationState = .pay,
        moneyFormatter: IMoneyFormatter = MoneyFormatter(),
        output: IPayButtonViewPresenterOutput? = nil
    ) {
        self.presentationState = presentationState
        self.moneyFormatter = moneyFormatter
        self.output = output
    }

    // MARK: IPayButtonViewOutput Methods

    func payButtonTapped() {
        output?.payButtonViewTapped(self)
    }

    // MARK: View Reloading

    private func setupView() {
        switch presentationState {
        case .pay:
            view?.set(configuration: .pay())
        case let .payWithAmount(amount):
            view?.set(configuration: .pay(amount: moneyFormatter.formatAmount(amount)))
        case .tinkoffPay:
            view?.set(configuration: .tinkoffPay())
        case .sbp:
            view?.set(configuration: .sbp())
        }

        view?.set(enabled: isEnabled)
        isLoading ? view?.startLoading() : view?.stopLoading()
    }
}

// MARK: - IPayButtonViewPresenterInput

extension PayButtonViewPresenter: IPayButtonViewPresenterInput {
    func startLoading() {
        isLoading = true
        view?.startLoading()
    }

    func stopLoading() {
        isLoading = false
        view?.stopLoading()
    }

    func set(enabled: Bool) {
        isEnabled = enabled
        view?.set(enabled: enabled)
    }
}

// MARK: - Button.Configuration + Helpers

private extension Button.Configuration {
    static func pay(amount: String? = nil) -> Button.Configuration {
        Button.Configuration(
            title: ["Оплатить", amount].compactMap { $0 }.joined(separator: " "),
            style: .primaryTinkoff,
            contentSize: .basicLarge
        )
    }

    static func tinkoffPay() -> Button.Configuration {
        Button.Configuration(
            title: "Оплатить с Тинькофф",
            image: Asset.TinkoffPay.tinkoffPaySmallNoBorder.image,
            style: .primaryTinkoff,
            contentSize: .basicLarge,
            imagePlacement: .trailing
        )
    }

    // Кнопка СБП не может быть в состоянии disabled, поэтому корректные цвета для этого не заданы.
    // Если появится необходимость, попросить дизайнера отрисовать это состояние, а затем положить цвет в `Button.Style`
    static func sbp() -> Button.Configuration {
        Button.Configuration(
            title: "Оплатить",
            image: Asset.Sbp.sbpLogoLight.image,
            style: Button.Style(
                foregroundColor: Button.InteractiveColor(normal: .white),
                backgroundColor: Button.InteractiveColor(normal: UIColor(hex: "#1D1346") ?? .clear)
            ),
            contentSize: modify(.basicLarge) { $0.imagePadding = 12 },
            imagePlacement: .trailing
        )
    }
}
