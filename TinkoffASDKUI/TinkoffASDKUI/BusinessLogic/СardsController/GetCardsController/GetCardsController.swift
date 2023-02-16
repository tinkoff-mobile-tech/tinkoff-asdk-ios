//
//  GetCardsController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

final class GetCardsController: IGetCardsController {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let customerKey: String
    private let availableCardStatuses: Set<PaymentCardStatus>

    // MARK: Init

    init(
        coreSDK: AcquiringSdk,
        customerKey: String,
        availableCardStatuses: Set<PaymentCardStatus> = [.active]
    ) {
        self.coreSDK = coreSDK
        self.customerKey = customerKey
        self.availableCardStatuses = availableCardStatuses
    }

    // MARK: IGetCardsController

    func getCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        let data = GetCardListData(customerKey: customerKey)

        coreSDK.getCardList(data: GetCardListData(customerKey: customerKey)) { [availableCardStatuses] result in
            let filteredCardsResult = result.map { cards in
                cards.filter { availableCardStatuses.contains($0.status) }
            }

            DispatchQueue.performOnMain {
                completion(filteredCardsResult)
            }
        }
    }
}
