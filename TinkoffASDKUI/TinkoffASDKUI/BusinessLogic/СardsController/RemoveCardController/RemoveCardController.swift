//
//  RemoveCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

final class RemoveCardController: IRemoveCardController {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let customerKey: String

    // MARK: Init

    init(coreSDK: AcquiringSdk, customerKey: String) {
        self.coreSDK = coreSDK
        self.customerKey = customerKey
    }

    // MARK: - IRemoveCardsController

    func removeCard(cardId: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let data = RemoveCardData(cardId: cardId, customerKey: customerKey)

        coreSDK.removeCard(data: data) { result in
            let removeResult = result.map { _ in () }

            DispatchQueue.performOnMain {
                completion(removeResult)
            }
        }
    }
}
