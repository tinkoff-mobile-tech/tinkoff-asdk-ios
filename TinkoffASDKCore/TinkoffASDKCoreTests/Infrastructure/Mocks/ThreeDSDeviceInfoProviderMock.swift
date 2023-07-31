//
//  ThreeDSDeviceInfoProviderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 21.12.2022.
//

import Foundation
import TinkoffASDKCore

final class ThreeDSDeviceInfoProviderMock: IThreeDSDeviceInfoProvider {

    // MARK: - createDeviceInfo

    typealias CreateDeviceInfoArguments = String

    var createDeviceInfoCallsCount = 0
    var createDeviceInfoReceivedArguments: CreateDeviceInfoArguments?
    var createDeviceInfoReceivedInvocations: [CreateDeviceInfoArguments?] = []
    var createDeviceInfoReturnValue: ThreeDSDeviceInfo = .fake()

    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo {
        createDeviceInfoCallsCount += 1
        let arguments = threeDSCompInd
        createDeviceInfoReceivedArguments = arguments
        createDeviceInfoReceivedInvocations.append(arguments)
        return createDeviceInfoReturnValue
    }
}

// MARK: - Resets

extension ThreeDSDeviceInfoProviderMock {
    func fullReset() {
        createDeviceInfoCallsCount = 0
        createDeviceInfoReceivedArguments = nil
        createDeviceInfoReceivedInvocations = []
    }
}
