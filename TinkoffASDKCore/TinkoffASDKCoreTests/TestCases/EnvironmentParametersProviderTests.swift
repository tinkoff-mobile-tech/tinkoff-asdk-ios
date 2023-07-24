//
//  EnvironmentParametersProviderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class EnvironmentParametersProviderTests: XCTestCase {
    // MARK: Properties

    private var deviceInfoProviderMock: DeviceInfoProviderMock!
    private var sut: EnvironmentParametersProvider!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        deviceInfoProviderMock = DeviceInfoProviderMock()
        sut = EnvironmentParametersProvider(
            deviceInfoProvider: deviceInfoProviderMock,
            language: .ru
        )
    }

    override func tearDown() {
        deviceInfoProviderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_environmentParameters() {
        // given
        deviceInfoProviderMock.systemVersion = .systemVersion
        deviceInfoProviderMock.modelVersion = .deviceModel

        // when
        let params = sut.environmentParameters

        // then
        XCTAssertEqual(params["connection_type"], "mobile_sdk")
        XCTAssertEqual(params["sdk_version"], Version.versionString)
        XCTAssertEqual(params["software_version"], .systemVersion)
        XCTAssertEqual(params["device_model"], .deviceModel)
        XCTAssertEqual(params["Language"], "ru")
    }
}

// MARK: - Constants

private extension String {
    static let systemVersion = "15.0"
    static let deviceModel = "iPhone"
}
