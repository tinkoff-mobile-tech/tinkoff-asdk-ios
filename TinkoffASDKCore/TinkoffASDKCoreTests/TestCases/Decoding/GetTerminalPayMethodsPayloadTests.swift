//
//  GetTerminalPayMethodsPayloadTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 30.11.2022.
//

@testable import TinkoffASDKCore
import XCTest

final class GetTerminalPayMethodsPayloadTests: XCTestCase {
    private let decoder = JSONDecoder()

    func test_initFromDecoder_withKnownPayMethods_shouldReturnPayloadWithAllMethods() throws {
        // given
        let stubData = try JSONStub("GetTerminalPayMethods_withKnownPayMethods").data()

        // when
        let payload = try decoder.decode(GetTerminalPayMethodsPayload.self, from: stubData)

        // then
        XCTAssertEqual(payload.terminalInfo.payMethods.count, 1)
    }

    func test_initFromDecoder_withUnknownPayMethods_shouldReturnPayloadWithKnownMethods() throws {
        // given
        let stubData = try JSONStub("GetTerminalPayMethods_withUnknownPayMethods").data()

        // when
        let payload = try decoder.decode(GetTerminalPayMethodsPayload.self, from: stubData)

        // then
        XCTAssertEqual(payload.terminalInfo.payMethods.count, 1)
    }

    func test_initFromDecoder_withoutPayMethods_shouldReturnPayloadWithEmptyPayMethods() throws {
        // given
        let stubData = try JSONStub("GetTerminalPayMethods_withoutPayMethods").data()

        // when
        let payload = try decoder.decode(GetTerminalPayMethodsPayload.self, from: stubData)

        // then
        XCTAssert(payload.terminalInfo.payMethods.isEmpty)
    }
}
