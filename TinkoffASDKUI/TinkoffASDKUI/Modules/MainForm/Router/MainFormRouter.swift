//
//  MainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import TinkoffASDKCore
import UIKit

final class MainFormRouter: IMainFormRouter {

    // MARK: Dependencies

    weak var transitionHandler: UIViewController?

    private let cardPaymentAssembly: ICardPaymentAssembly
    private let acquiringSdk: AcquiringSdk // Временно, удалить потом
    private let customerKey: String? // Временно, удалить потом

    // MARK: Properties

    private var activeCards = [PaymentCard]() // Временно, удалить потом

    // MARK: Initialization

    init(
        cardPaymentAssembly: ICardPaymentAssembly,
        acquiringSdk: AcquiringSdk,
        customerKey: String?
    ) {
        self.cardPaymentAssembly = cardPaymentAssembly
        self.acquiringSdk = acquiringSdk // Временно, удалить потом
        self.customerKey = customerKey // Временно, удалить потом

        loadCardList() // Временно, удалить потом
    }
}

// MARK: - IMainFormRouter

extension MainFormRouter {
    func openCardPaymentForm() {
        let customerEmail = Int.random(in: 0 ... 100) % 2 == 0 ? "some123what@asdk.com" : ""
        let cardPaymentVC = cardPaymentAssembly.build(activeCards: activeCards, customerEmail: customerEmail)
        let navVC = UINavigationController(rootViewController: cardPaymentVC)
        transitionHandler?.present(navVC, animated: true, completion: nil)
    }
}

// MARK: - Private

extension MainFormRouter {
    private func loadCardList() { // Временно, удалить потом
//        if let customerKey = customerKey {
        let cardListData = GetCardListData(customerKey: "TestSDK_CustomerKey1")
        acquiringSdk.getCardList(data: cardListData, completion: { [weak self] result in
            switch result {
            case let .success(cards):
                self?.activeCards = cards.filter { $0.status == .active }
                print("fetch cards: \(cards)")
            case let .failure(error):
                print("fetch cards error: \(error)")
            }
        })
//        }
    }
}
