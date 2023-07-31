//
//  DeviceInfoProviderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 25.07.2023.
//

import Foundation
@testable import TinkoffASDKCore
import XCTest

final class DeviceInfoProviderTests: XCTestCase {
    // MARK: Properties

    private var sut: DeviceInfoProvider!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        sut = DeviceInfoProvider()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatProviderHasDeviceModel() {
        // when
        let model = sut.model

        // then
        XCTAssertEqual(model, UIDevice.current.localizedModel)
    }

    func test_thatProviderHasSystemName() {
        // when
        let model = sut.systemName

        // then
        XCTAssertEqual(model, UIDevice.current.systemName)
    }

    func test_thatProviderHasSystemVersion() {
        // when
        let model = sut.systemVersion

        // then
        XCTAssertEqual(model, UIDevice.current.systemVersion)
    }
}
