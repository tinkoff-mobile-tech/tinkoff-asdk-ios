//
//  YandexPayMethodProviderMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import TinkoffASDKYandexPay

final class YandexPayMethodProviderMock: IYandexPayMethodProvider {

    // MARK: - provideMethod

    typealias ProvideMethodArguments = (Result<YandexPayMethod, Error>) -> Void

    var provideMethodCallsCount = 0
    var provideMethodReceivedArguments: ProvideMethodArguments?
    var provideMethodReceivedInvocations: [ProvideMethodArguments?] = []
    var provideMethodCompletionClosureInput: Result<YandexPayMethod, Error>?

    func provideMethod(completion: @escaping (Result<YandexPayMethod, Error>) -> Void) {
        provideMethodCallsCount += 1
        let arguments = completion
        provideMethodReceivedArguments = arguments
        provideMethodReceivedInvocations.append(arguments)
        if let provideMethodCompletionClosureInput = provideMethodCompletionClosureInput {
            completion(provideMethodCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension YandexPayMethodProviderMock {
    func fullReset() {
        provideMethodCallsCount = 0
        provideMethodReceivedArguments = nil
        provideMethodReceivedInvocations = []
        provideMethodCompletionClosureInput = nil
    }
}
