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

    func test_returnsError_whenCertsAreEmpty() {
        // given
        let paymentSystem = "Some"

        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [])

        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)

        // when
        var result: Result<String, Error>?
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: { result = $0 })

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(TDSFlowError.invalidPaymentSystem as NSError, error as NSError)
        } else {
            XCTFail()
        }
    }

    func test_filterCerts() throws {
        // given
        let paymentSystem = "Some"
        let directoryServerID = "123"

        let certificate1 = CertificateData.fake(type: .rootCA, algorithm: .ec, forceUpdateFlag: false)
        let certificate2 = CertificateData.fake(type: .publicKey, algorithm: .rsa, forceUpdateFlag: false)
        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [certificate1, certificate2])

        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)
        tdsWrapperMock.checkCertificatesReturnValue = [CertificateStateStub(directoryServerID: directoryServerID)]

        // when
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: { _ in })

        // then
        let certs = try XCTUnwrap(tdsWrapperMock.updateReceivedArguments?.requests)

        XCTAssertEqual(certs.count, 2)
        XCTAssertEqual(certs[0].directoryServerID, directoryServerID)
        XCTAssertEqual(certs[0].certificateType, .dsRootCA)
        XCTAssertEqual(certs[0].sha256Fingerprint, certificate1.sha256Fingerprint)
        XCTAssertEqual(certs[1].directoryServerID, directoryServerID)
        XCTAssertEqual(certs[1].certificateType, .dsPublicKey)
        XCTAssertEqual(certs[1].sha256Fingerprint, certificate2.sha256Fingerprint)
    }

    func test_filterCerts_empty() throws {
        // given
        let paymentSystem = "Some"
        let directoryServerID = "123"

        let certificate1 = CertificateData.fake(type: .publicKey, algorithm: .ec, forceUpdateFlag: false)
        let payload = Get3DSAppBasedCertsConfigPayload.fake(certificates: [certificate1])

        tdsWrapperMock.checkCertificatesReturnValue = [
            CertificateStateStub(
                certificateType: .dsPublicKey,
                directoryServerID: directoryServerID,
                sha256Fingerprint: "some"
            ),
        ]
        acquiringSdkMock.getCertsConfigCompletionClosureInput = .success(payload)

        // when
        var result: Result<String, Error>?
        sut.checkAndUpdateCertsIfNeeded(for: paymentSystem, completion: { result = $0 })

        // then
        if case let .success(data) = result {
            XCTAssertEqual(data, directoryServerID)
        } else {
            XCTFail()
        }
    }
}
