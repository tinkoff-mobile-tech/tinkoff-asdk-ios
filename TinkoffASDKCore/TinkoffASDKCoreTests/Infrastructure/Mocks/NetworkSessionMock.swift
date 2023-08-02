//
//  NetworkSessionMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkSessionMock: INetworkSession {

    // MARK: - dataTask

    typealias DataTaskArguments = (request: URLRequest, completion: (Data?, URLResponse?, Error?) -> Void)

    var dataTaskCallsCount = 0
    var dataTaskReceivedArguments: DataTaskArguments?
    var dataTaskReceivedInvocations: [DataTaskArguments?] = []
    var dataTaskCompletionClosureInput: (Data?, URLResponse?, Error?)? = (Data(), HTTPURLResponse(), nil)
    var dataTaskReturnValue = NetworkDataTaskMock()

    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> INetworkDataTask {
        dataTaskCallsCount += 1
        let arguments = (request, completion)
        dataTaskReceivedArguments = arguments
        dataTaskReceivedInvocations.append(arguments)
        if let dataTaskCompletionClosureInput = dataTaskCompletionClosureInput {
            completion(
                dataTaskCompletionClosureInput.0,
                dataTaskCompletionClosureInput.1,
                dataTaskCompletionClosureInput.2
            )
        }
        return dataTaskReturnValue
    }
}

// MARK: - Resets

extension NetworkSessionMock {
    func fullReset() {
        dataTaskCallsCount = 0
        dataTaskReceivedArguments = nil
        dataTaskReceivedInvocations = []
        dataTaskCompletionClosureInput = nil
    }
}
