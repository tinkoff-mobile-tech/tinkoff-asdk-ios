//
//  EnvironmentParametersProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 11.12.2022.
//

import Foundation

protocol IEnvironmentParametersProvider {
    var environmentParameters: [String: String] { get }
}

final class EnvironmentParametersProvider {
    // MARK: Dependencies

    private let deviceInfoProvider: IDeviceInfoProvider
    private let language: AcquiringSdkLanguage?

    // MARK: Init

    init(deviceInfoProvider: IDeviceInfoProvider, language: AcquiringSdkLanguage?) {
        self.deviceInfoProvider = deviceInfoProvider
        self.language = language
    }
}

// MARK: - IEnvironmentParametersProvider

extension EnvironmentParametersProvider: IEnvironmentParametersProvider {
    var environmentParameters: [String: String] {
        let parameters: [String: String] = [
            .connectionType: .mobileSDK,
            .version: Version.versionString,
            .softwareVersion: deviceInfoProvider.systemVersion,
            .deviceModel: deviceInfoProvider.modelVersion,
            Constants.Keys.language: language?.rawValue,
        ].compactMapValues { $0 }

        return parameters
    }
}

// MARK: - Constants

private extension String {
    static let mobileSDK = "mobile_sdk"
    static let connectionType = "connection_type"
    static let version = "sdk_version"
    static let softwareVersion = "software_version"
    static let deviceModel = "device_model"
}
