//
//  TDSFlowErrorTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 12.07.2023.
//

import ThreeDSWrapper
@testable import TinkoffASDKUI
import XCTest

final class TDSFlowErrorTests: XCTestCase {
    func test_thatFlowErrorHasCorrectLocalization_whenErrorIsTimeout() {
        // when
        let error = TDSFlowError.timeout

        // then
        XCTAssertEqual(error.localizedDescription, Loc.TinkoffAcquiring.Threeds.Error.timeout)
    }

    func test_thatFlowErrorHasCorrectLocalization_whenErrorIsInvalidPaymentSystem() {
        // when
        let error = TDSFlowError.invalidPaymentSystem

        // then
        XCTAssertEqual(error.localizedDescription, Loc.TinkoffAcquiring.Threeds.Error.invalidPaymentSystem)
    }

    func test_thatFlowErrorHasCorrectLocalization_whenErrorIsUpdatingCertsError() {
        // given
        let certMock = CertificateUpdatingRequest.fake()
        let errorMock = TDSWrapperError(code: .certificateDataIsCorrupted, message: "Message")
        let data = [certMock: errorMock]

        // when
        let error = TDSFlowError.updatingCertsError(data)

        // then
        XCTAssertEqual(
            error.localizedDescription,
            Loc.TinkoffAcquiring.Threeds.Error.updatingCertsError + String(describing: data)
        )
    }

    func test_thatFlowErrorsAreNotEqual() {
        // given
        let error1 = TDSFlowError.timeout
        let error2 = TDSFlowError.invalidPaymentSystem

        // then
        XCTAssertNotEqual(error1, error2)
    }

    func test_thatFlowErrorsAreEqual() {
        // given
        let error1 = TDSWrapperError(code: .certificateDataIsCorrupted, message: "Message")
        let error2 = TDSWrapperError(code: .certificateDataIsCorrupted, message: "Message")

        // then
        XCTAssertTrue(error1 == error2)
    }
}
