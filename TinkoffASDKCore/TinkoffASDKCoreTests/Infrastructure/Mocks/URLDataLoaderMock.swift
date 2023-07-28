//
//  URLDataLoaderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class URLDataLoaderMock: IURLDataLoader {

    // MARK: - loadData

    typealias LoadDataArguments = (url: URL, completion: (Result<Data, Error>) -> Void)

    var loadDataCallsCount = 0
    var loadDataReceivedArguments: LoadDataArguments?
    var loadDataReceivedInvocations: [LoadDataArguments?] = []
    var loadDataCompletionClosureInput: Result<Data, Error>?
    var loadDataReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func loadData(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        loadDataCallsCount += 1
        let arguments = (url, completion)
        loadDataReceivedArguments = arguments
        loadDataReceivedInvocations.append(arguments)
        if let loadDataCompletionClosureInput = loadDataCompletionClosureInput {
            completion(loadDataCompletionClosureInput)
        }
        return loadDataReturnValue
    }
}

// MARK: - Resets

extension URLDataLoaderMock {
    func fullReset() {
        loadDataCallsCount = 0
        loadDataReceivedArguments = nil
        loadDataReceivedInvocations = []
        loadDataCompletionClosureInput = nil
    }
}
