//
//  ITDSWrapper.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.04.2023.
//

import Foundation
import TdsSdkIos
import ThreeDSWrapper

protocol ITransaction {
    func getAuthenticationRequestParameters() throws -> AuthenticationRequestParameters

    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeout: Int
    )

    func getProgressView() -> ProgressDialog
    func close()
}

protocol ITDSWrapper {

    /// Создание 3DS-транзакции
    func createTransaction(
        directoryServerID: String,
        messageVersion: String
    ) throws -> ITransaction
}

extension TDSWrapper: ITDSWrapper {

    func createTransaction(directoryServerID: String, messageVersion: String) throws -> ITransaction {
        let transaction: Transaction = try createTransaction(
            directoryServerID: directoryServerID,
            messageVersion: messageVersion
        )

        return transaction
    }
}

extension Transaction: ITransaction {}
