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

    // MARK: - checkCertificates

    var checkCertificatesCallsCount = 0
    var checkCertificatesReturnValue: [CertificateState]!

    func checkCertificates() -> [CertificateState] {
        checkCertificatesCallsCount += 1
        return checkCertificatesReturnValue
    }

    // MARK: - update

    typealias UpdateArguments = (requests: [CertificateUpdatingRequest], queue: DispatchQueue, completion: ([CertificateUpdatingRequest: TDSWrapperError]) -> Void)

    var updateCallsCount = 0
    var updateReceivedArguments: UpdateArguments?
    var updateReceivedInvocations: [UpdateArguments] = []
    var updateCompletionClosureInput: [CertificateUpdatingRequest: TDSWrapperError]?

    func update(with requests: [CertificateUpdatingRequest], receiveOn queue: DispatchQueue, _ completion: @escaping ([CertificateUpdatingRequest: TDSWrapperError]) -> Void) {
        updateCallsCount += 1
        let arguments = (requests, queue, completion)
        updateReceivedArguments = arguments
        updateReceivedInvocations.append(arguments)
        if let updateCompletionClosureInput = updateCompletionClosureInput {
            completion(updateCompletionClosureInput)
        }
    }
}
