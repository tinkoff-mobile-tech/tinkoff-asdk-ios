//
//  DataLoaderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 10.07.2023.
//

import Foundation
import TinkoffASDKCore

final class DataLoaderMock: IDataLoader {

    // MARK: - loadData

    typealias LoadDataArguments = (url: URL, completion: (Result<Data, Error>) -> Void)

    var loadDataCallsCount = 0
    var loadDataReceivedArguments: LoadDataArguments?
    var loadDataReceivedInvocations: [LoadDataArguments?] = []
    var loadDataCompletionClosureInput: Result<Data, Error>?
    var loadDataReturnValue: Cancellable = CancellableMock()

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

extension DataLoaderMock {
    func fullReset() {
        loadDataCallsCount = 0
        loadDataReceivedArguments = nil
        loadDataReceivedInvocations = []
        loadDataCompletionClosureInput = nil
    }
}
