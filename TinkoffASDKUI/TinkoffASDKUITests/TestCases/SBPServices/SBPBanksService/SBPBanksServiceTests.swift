//
//  SBPBanksServiceTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBanksServiceTests: BaseTestCase {

    var sut: SBPBanksService!

    // MARK: Mocks

    var acquiringSBPServiceMock: AcquiringSBPAndPaymentServiceMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        acquiringSBPServiceMock = AcquiringSBPAndPaymentServiceMock()
        sut = SBPBanksService(acquiringSBPService: acquiringSBPServiceMock)
    }

    override func tearDown() {
        acquiringSBPServiceMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_loadBanks_success() throws {
        // given
        let payloadBanks = [SBPBank](repeating: .fake, count: 5)
        let payload = GetSBPBanksPayload(banks: payloadBanks)
        acquiringSBPServiceMock.loadSBPBanksCompletionClosureInput = .success(payload)

        var isSuccessLoaded = false
        var loadedBanks = [SBPBank]()
        let completion: SBPBanksServiceLoadBanksCompletion = { result in
            switch result {
            case let .success(banks):
                isSuccessLoaded = true
                loadedBanks = banks
            case .failure:
                isSuccessLoaded = false
            }
        }

        // when
        sut.loadBanks(completion: completion)

        // then
        XCTAssertTrue(isSuccessLoaded)
        XCTAssertEqual(loadedBanks, payloadBanks)
        XCTAssertEqual(acquiringSBPServiceMock.loadSBPBanksCallsCount, 1)
    }

    func test_loadBanks_failure() throws {
        // given
        let error = NSError(domain: "error", code: 123456)
        acquiringSBPServiceMock.loadSBPBanksCompletionClosureInput = .failure(error)

        var isSuccessLoaded = false
        let completion: SBPBanksServiceLoadBanksCompletion = { result in
            switch result {
            case .success: isSuccessLoaded = true
            case .failure: isSuccessLoaded = false
            }
        }

        // when
        sut.loadBanks(completion: completion)

        // then
        XCTAssertFalse(isSuccessLoaded)
        XCTAssertEqual(acquiringSBPServiceMock.loadSBPBanksCallsCount, 1)
    }
}
