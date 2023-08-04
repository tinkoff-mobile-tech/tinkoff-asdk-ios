//
//  ThreeDSDeviceInfoProviderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 21.12.2022.
//

import Foundation
import TinkoffASDKCore

final class ThreeDSDeviceInfoProviderMock: IThreeDSDeviceInfoProvider {

    // MARK: - createThreeDsDataBrowser

    typealias CreateThreeDsDataBrowserArguments = String

    var createThreeDsDataBrowserCallsCount = 0
    var createThreeDsDataBrowserReceivedArguments: CreateThreeDsDataBrowserArguments?
    var createThreeDsDataBrowserReceivedInvocations: [CreateThreeDsDataBrowserArguments?] = []
    var createThreeDsDataBrowserReturnValue: ThreeDsDataBrowser!

    func createThreeDsDataBrowser(threeDSCompInd: String) -> ThreeDsDataBrowser {
        createThreeDsDataBrowserCallsCount += 1
        let arguments = threeDSCompInd
        createThreeDsDataBrowserReceivedArguments = arguments
        createThreeDsDataBrowserReceivedInvocations.append(arguments)
        return createThreeDsDataBrowserReturnValue
    }

    // MARK: - createThreeDsDataSDK

    typealias CreateThreeDsDataSDKArguments = (sdkAppID: String, sdkEphemPubKey: String, sdkReferenceNumber: String, sdkTransID: String, sdkMaxTimeout: String, sdkEncData: String)

    var createThreeDsDataSDKCallsCount = 0
    var createThreeDsDataSDKReceivedArguments: CreateThreeDsDataSDKArguments?
    var createThreeDsDataSDKReceivedInvocations: [CreateThreeDsDataSDKArguments?] = []
    var createThreeDsDataSDKReturnValue: ThreeDsDataSDK!

    func createThreeDsDataSDK(sdkAppID: String, sdkEphemPubKey: String, sdkReferenceNumber: String, sdkTransID: String, sdkMaxTimeout: String, sdkEncData: String) -> ThreeDsDataSDK {
        createThreeDsDataSDKCallsCount += 1
        let arguments = (sdkAppID, sdkEphemPubKey, sdkReferenceNumber, sdkTransID, sdkMaxTimeout, sdkEncData)
        createThreeDsDataSDKReceivedArguments = arguments
        createThreeDsDataSDKReceivedInvocations.append(arguments)
        return createThreeDsDataSDKReturnValue
    }
}

// MARK: - Resets

extension ThreeDSDeviceInfoProviderMock {
    func fullReset() {
        createThreeDsDataBrowserCallsCount = 0
        createThreeDsDataBrowserReceivedArguments = nil
        createThreeDsDataBrowserReceivedInvocations = []

        createThreeDsDataSDKCallsCount = 0
        createThreeDsDataSDKReceivedArguments = nil
        createThreeDsDataSDKReceivedInvocations = []
    }
}
