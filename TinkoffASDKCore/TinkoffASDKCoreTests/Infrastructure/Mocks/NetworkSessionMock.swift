//
//  NetworkSessionMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkSessionMock: INetworkSession {
    var invokedDataTask = false
    var invokedDataTaskCount = 0
    var invokedDataTaskParameters: (request: URLRequest, Void)?
    var invokedDataTaskParametersList = [(request: URLRequest, Void)]()
    var stubbedDataTaskCompletionResult: (Data?, URLResponse?, Error?)?
    var stubbedDataTaskResult = NetworkDataTaskMock()

    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> INetworkDataTask {
        invokedDataTask = true
        invokedDataTaskCount += 1
        invokedDataTaskParameters = (request, ())
        invokedDataTaskParametersList.append((request, ()))
        if let result = stubbedDataTaskCompletionResult {
            completion(result.0, result.1, result.2)
        }
        return stubbedDataTaskResult
    }
}
