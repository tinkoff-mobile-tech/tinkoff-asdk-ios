//
//  PayButtonPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import UIKit

final class PayButtonViewPresenter: IPayButtonViewOutput, IPayButtonViewPresenterInput {
    // MARK: IPayButtonView Properties

    var view: IPayButtonViewInput? {
        didSet { setupView() }
    }

    // MARK: IPayButtonViewPresenterInput Properties

    weak var output: IPayButtonViewPresenterOutput?

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

    // MARK: IPayButtonViewPresenterInput Methods

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

    // MARK: IPayButtonViewOutput Methods

    func payButtonTapped() {
        output?.payButtonViewTapped(self)
    }

    // MARK: View Reloading

    private func setupView() {
        switch presentationState {
        case .pay:
            view?.set(configuration: .pay(title: "Оплатить"))
        case .payByCard:
            view?.set(configuration: .pay(title: "Оплатить по карте"))
        case let .payWithAmount(amount):
            view?.set(configuration: .pay(title: "Оплатить \(moneyFormatter.formatAmount(amount))"))
        case .tinkoffPay:
            view?.set(configuration: .tinkoffPay())
        case .sbp:
            view?.set(configuration: .sbp())
        }

        view?.set(enabled: isEnabled)
        isLoading ? view?.startLoading() : view?.stopLoading()
    }
}

// MARK: - Button.Configuration + Helpers

private extension Button.Configuration {
    static func pay(title: String) -> Button.Configuration {
        Button.Configuration(
            title: title,
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
