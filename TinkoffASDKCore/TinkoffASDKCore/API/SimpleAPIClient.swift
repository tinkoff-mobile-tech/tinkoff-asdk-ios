//
//  SimpleAPIClient.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 02.10.2022.
//

import Foundation

protocol ISimpleAPIClient {
    func perform(_ request: NetworkRequest) -> Cancellable
}

final class SimpleAPIClient {
    private let networkClient: INetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
}
