//
//  URLDataLoader.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 25.12.2022.
//

import Foundation

/// Загружает `Data` по заданному `URLRequest`
protocol IURLDataLoader {
    /// Загружает `Data` по заданному `URLRequest`
    @discardableResult
    func loadData(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable
}

final class URLDataLoader: IURLDataLoader {
    private let networkClient: INetworkClient

    init(networkClient: INetworkClient) {
        self.networkClient = networkClient
    }

    @discardableResult
    func loadData(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        networkClient.performRequest(URLRequest(url: url)) { result in
            let dataResult = result
                .map(\.data)
                .mapError { $0 as Error }

            completion(dataResult)
        }
    }
}
