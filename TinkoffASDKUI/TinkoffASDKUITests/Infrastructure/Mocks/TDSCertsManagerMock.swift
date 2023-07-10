//
//  TDSCertsManagerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class TDSCertsManagerMock: ITDSCertsManager {

    // MARK: - checkAndUpdateCertsIfNeeded

    typealias CheckAndUpdateCertsIfNeededArguments = (paymentSystem: String, completion: (_ matchingDirectoryServerID: Result<String, Error>) -> Void)

    var checkAndUpdateCertsIfNeededCallsCount = 0
    var checkAndUpdateCertsIfNeededReceivedArguments: CheckAndUpdateCertsIfNeededArguments?
    var checkAndUpdateCertsIfNeededReceivedInvocations: [CheckAndUpdateCertsIfNeededArguments] = []
    var checkAndUpdateCertsIfNeededCompletionClosureInput: Result<String, Error>?

    func checkAndUpdateCertsIfNeeded(for paymentSystem: String, completion: @escaping (_ matchingDirectoryServerID: Result<String, Error>) -> Void) {
        checkAndUpdateCertsIfNeededCallsCount += 1
        let arguments = (paymentSystem, completion)
        checkAndUpdateCertsIfNeededReceivedArguments = arguments
        checkAndUpdateCertsIfNeededReceivedInvocations.append(arguments)
        if let checkAndUpdateCertsIfNeededCompletionClosureInput = checkAndUpdateCertsIfNeededCompletionClosureInput {
            completion(checkAndUpdateCertsIfNeededCompletionClosureInput)
        }
    }
}
