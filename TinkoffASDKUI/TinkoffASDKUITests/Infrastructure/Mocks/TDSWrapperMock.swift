//
//  TDSWrapperMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.04.2023.
//

import ThreeDSWrapper
@testable import TinkoffASDKUI

final class TDSWrapperMock: ITDSWrapper {

    // MARK: - createTransaction

    typealias CreateTransactionArguments = (directoryServerID: String, messageVersion: String)

    var createTransactionThrowableError: Error?
    var createTransactionCallsCount = 0
    var createTransactionReceivedArguments: CreateTransactionArguments?
    var createTransactionReceivedInvocations: [CreateTransactionArguments] = []
    var createTransactionReturnValue: ITransaction!

    func createTransaction(directoryServerID: String, messageVersion: String) throws -> ITransaction {
        if let error = createTransactionThrowableError {
            throw error
        }
        createTransactionCallsCount += 1
        let arguments = (directoryServerID, messageVersion)
        createTransactionReceivedArguments = arguments
        createTransactionReceivedInvocations.append(arguments)
        return createTransactionReturnValue
    }
}
