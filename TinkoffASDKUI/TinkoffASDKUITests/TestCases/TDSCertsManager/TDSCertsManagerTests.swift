//
//  TDSCertsManagerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 03.07.2023.
//

import Foundation
import ThreeDSWrapper
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

    func test_checkAndUpdateCertsIfNeeded_success() {
        // given
        let paymentSystem = "Some"

        let certificate1 = CertificateData.fake(type: .rootCA, algorithm: .ec, forceUpdateFlag: false)
        let certificate2 = CertificateData.fake(type: .publicKey, algorithm: .rsa, forceUpdateFlag: true)
        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [certificate1, certificate2])

        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)
        tdsWrapperMock.updateCompletionClosureInput = [:]
        var serverId: String?
        var error: Error?
        let completion: (Result<String, Error>) -> Void = { result in
            switch result {
            case let .success(servId):
                serverId = servId
            case let .failure(err):
                error = err
            }
        }

        // when
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: completion)

        // then
        XCTAssertEqual(acquiringSdkMock.getCertsConfigCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.checkCertificatesCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.updateCallsCount, 1)
        XCTAssertEqual(serverId, certificate1.directoryServerID)
        XCTAssertNil(error)
    }

    func test_checkAndUpdateCertsIfNeeded_failure() {
        // given
        let paymentSystem = "Some"

        let getSertsError = TestsError.basic
        acquiringSdkMock.getCertsConfigCompletionClosureInput = .failure(getSertsError)
        tdsWrapperMock.updateCompletionClosureInput = [:]

        var serverId: String?
        var error: TestsError?
        let completion: (Result<String, Error>) -> Void = { result in
            switch result {
            case let .success(servId):
                serverId = servId
            case let .failure(err):
                error = err as? TestsError
            }
        }

        // when
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: completion)

        // then
        XCTAssertEqual(acquiringSdkMock.getCertsConfigCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.checkCertificatesCallsCount, 0)
        XCTAssertEqual(tdsWrapperMock.updateCallsCount, 0)
        XCTAssertEqual(serverId, nil)
        XCTAssertEqual(error, getSertsError)
    }

    func test_checkAndUpdateCertsIfNeeded_failure_no_metching() {
        // given
        let paymentSystem = "not valid"

        let certificate1 = CertificateData.fake(type: .publicKey, algorithm: .rsa, forceUpdateFlag: true)
        let certificate2 = CertificateData.fake(type: .rootCA, algorithm: .ec, forceUpdateFlag: false)
        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [certificate1, certificate2])

        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)
        tdsWrapperMock.updateCompletionClosureInput = [:]

        var serverId: String?
        var error: Error?
        let completion: (Result<String, Error>) -> Void = { result in
            switch result {
            case let .success(servId):
                serverId = servId
            case let .failure(err):
                error = err
            }
        }

        // when
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: completion)

        // then
        XCTAssertEqual(acquiringSdkMock.getCertsConfigCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.checkCertificatesCallsCount, 0)
        XCTAssertEqual(tdsWrapperMock.updateCallsCount, 0)
        XCTAssertEqual(serverId, nil)
        XCTAssertEqual(error as? TDSFlowError, TDSFlowError.invalidPaymentSystem)
    }

    func test_checkAndUpdateCertsIfNeeded_success_failure_tdsWrapper() {
        // given
        let paymentSystem = "Some"

        let certificate1 = CertificateData.fake(type: .rootCA, algorithm: .ec, forceUpdateFlag: false)
        let certificate2 = CertificateData.fake(type: .publicKey, algorithm: .rsa, forceUpdateFlag: false)
        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [certificate1, certificate2])

        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)

        let tdsRequest = CertificateUpdatingRequest.fake()
        let tdsError = TDSWrapperError(code: TDSWrapperError.Code.internalError, message: "asd")
        let failures: [CertificateUpdatingRequest: TDSWrapperError] = [tdsRequest: tdsError]
        tdsWrapperMock.updateCompletionClosureInput = failures

        var serverId: String?
        var error: TDSFlowError?
        let completion: (Result<String, Error>) -> Void = { result in
            switch result {
            case let .success(servId):
                serverId = servId
            case let .failure(err):
                error = err as? TDSFlowError
            }
        }

        // when
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: completion)

        // then
        XCTAssertEqual(acquiringSdkMock.getCertsConfigCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.checkCertificatesCallsCount, 1)
        XCTAssertEqual(tdsWrapperMock.updateCallsCount, 1)
        XCTAssertEqual(serverId, nil)
        XCTAssertEqual(error, TDSFlowError.updatingCertsError(failures))
    }
}

// MARK: - Helpers

extension Get3DSAppBasedCertsConfigPayload {
    static func fake(certificates: [CertificateData]) -> Get3DSAppBasedCertsConfigPayload {
        Get3DSAppBasedCertsConfigPayload(certificates: certificates)
    }
}

extension CertificateData {
    static func fake(type: CertificateType, algorithm: CertificateAlgorithm, forceUpdateFlag: Bool) -> CertificateData {
        CertificateData(
            paymentSystem: "Some",
            directoryServerID: "123",
            type: type,
            url: .doesNotMatter,
            notAfterDate: .distantFuture,
            sha256Fingerprint: "some",
            algorithm: algorithm,
            forceUpdateFlag: forceUpdateFlag
        )
    }
}

extension CertificateUpdatingRequest {
    static func fake() -> CertificateUpdatingRequest {
        CertificateUpdatingRequest(
            certificateType: .dsRootCA,
            directoryServerID: "asd",
            algorithm: .ec,
            notAfterDate: .distantFuture,
            sha256Fingerprint: "asd",
            url: .doesNotMatter
        )
    }
}
