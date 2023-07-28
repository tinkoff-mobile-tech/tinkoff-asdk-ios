//
//  ThreeDSDeviceInfoProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
import TinkoffASDKCore

final class ThreeDSDeviceInfoProviderMock: IThreeDSDeviceInfoProvider {
    var invokedCreateDeviceInfo = false
    var invokedCreateDeviceInfoCount = 0
    var invokedCreateDeviceInfoParameters: (threeDSCompInd: String, Void)?
    var invokedCreateDeviceInfoParametersList = [(threeDSCompInd: String, Void)]()
    var stubbedCreateDeviceInfoResult = ThreeDSDeviceInfo.fake()

    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo {
        invokedCreateDeviceInfo = true
        invokedCreateDeviceInfoCount += 1
        invokedCreateDeviceInfoParameters = (threeDSCompInd, ())
        invokedCreateDeviceInfoParametersList.append((threeDSCompInd, ()))
        return stubbedCreateDeviceInfoResult
    }
}
