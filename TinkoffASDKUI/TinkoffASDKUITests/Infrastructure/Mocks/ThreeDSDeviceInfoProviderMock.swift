//
//  ThreeDSDeviceInfoProviderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 21.12.2022.
//

import Foundation
import TinkoffASDKCore

final class ThreeDSDeviceInfoProviderMock: IThreeDSDeviceInfoProvider {
    var invokedCreateDeviceInfo = false
    var invokedCreateDeviceInfoCount = 0
    var invokedCreateDeviceInfoParameters: (threeDSCompInd: String, Void)?
    var invokedCreateDeviceInfoParametersList = [(threeDSCompInd: String, Void)]()
    var stubbedCreateDeviceInfoResult = ThreeDSDeviceInfo(cresCallbackUrl: URL.empty.absoluteString, screenWidth: 300, screenHeight: 800)

    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo {
        invokedCreateDeviceInfo = true
        invokedCreateDeviceInfoCount += 1
        invokedCreateDeviceInfoParameters = (threeDSCompInd, ())
        invokedCreateDeviceInfoParametersList.append((threeDSCompInd, ()))
        return stubbedCreateDeviceInfoResult
    }
}
