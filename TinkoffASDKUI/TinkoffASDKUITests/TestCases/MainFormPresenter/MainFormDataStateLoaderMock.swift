//
//  MainFormDataStateLoaderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormDataStateLoaderMock: IMainFormDataStateLoader {

    // MARK: - loadState

    typealias LoadStateArguments = (paymentFlow: PaymentFlow, completion: (Result<MainFormDataState, Error>) -> Void)

    var loadStateCallsCount = 0
    var loadStateReceivedArguments: LoadStateArguments?
    var loadStateReceivedInvocations: [LoadStateArguments] = []
    var loadStateCompletionClosureInput: Result<MainFormDataState, Error>?

    func loadState(for paymentFlow: PaymentFlow, completion: @escaping (Result<MainFormDataState, Error>) -> Void) {
        loadStateCallsCount += 1
        let arguments = (paymentFlow, completion)
        loadStateReceivedArguments = arguments
        loadStateReceivedInvocations.append(arguments)
        if let loadStateCompletionClosureInput = loadStateCompletionClosureInput {
            completion(loadStateCompletionClosureInput)
        }
    }
}
