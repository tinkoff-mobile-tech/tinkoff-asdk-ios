//
//  DefaultAuthChallengeServiceTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

import TinkoffASDKCore
import XCTest

final class DefaultAuthChallengeServiceTests: XCTestCase {
    // MARK: Properties

    private var certificateValidatorMock: CertificateValidatorMock!
    private var sut: DefaultAuthChallengeService!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        certificateValidatorMock = CertificateValidatorMock()
        sut = DefaultAuthChallengeService(certificateValidator: certificateValidatorMock)
    }

    // MARK: Tests

    func test_thatServiceUsesCredential_whenValidationDidCompleteSuccessful() {
        // given
        let expectation = expectation(description: #function)
        certificateValidatorMock.isValidReturnValue = true

        // when
        var disposition: URLSession.AuthChallengeDisposition?
        sut.didReceive(challenge: URLAuthenticationChallengeMock(), completionHandler: { dis, _ in
            disposition = dis
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(disposition, .useCredential)
    }

    func test_thatServiceUsesCredential_whenValidationDidFail() {
        // given
        let expectation = expectation(description: #function)
        certificateValidatorMock.isValidReturnValue = false

        // when
        var disposition: URLSession.AuthChallengeDisposition?
        sut.didReceive(challenge: URLAuthenticationChallengeMock(), completionHandler: { dis, _ in
            disposition = dis
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(disposition, .performDefaultHandling)
    }

    func test_thatServiceDoesNotUseCredential_whenSecTrustIsNil() {
        // given
        let challengeMock = URLAuthenticationChallengeMock()
        challengeMock.internalServerTrust = nil

        let expectation = expectation(description: #function)
        certificateValidatorMock.isValidReturnValue = false

        // when
        var disposition: URLSession.AuthChallengeDisposition?
        sut.didReceive(challenge: challengeMock, completionHandler: { dis, _ in
            disposition = dis
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(disposition, .performDefaultHandling)
    }
}
