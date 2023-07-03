//
//  TDSCertsManagerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 03.07.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TDSCertsManagerTests: BaseTestCase {

    var sut: TDSCertsManager!

    // Mocks

    var acquiringSdkMock: AcquiringThreeDsServiceMock!
    var tdsWrapperMock: TDSWrapperMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        acquiringSdkMock = AcquiringThreeDsServiceMock()
        tdsWrapperMock = TDSWrapperMock()

        sut = TDSCertsManager(acquiringSdk: acquiringSdkMock, tdsWrapper: tdsWrapperMock)
    }

    override func tearDown() {
        acquiringSdkMock = nil
        tdsWrapperMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test() {
        XCTAssertTrue(true)
    }
}
