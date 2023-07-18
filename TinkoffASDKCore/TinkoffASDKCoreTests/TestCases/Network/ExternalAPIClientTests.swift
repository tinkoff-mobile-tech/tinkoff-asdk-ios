//
//  ExternalAPIClientTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 18.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class ExternalAPIClientTests: XCTestCase {
    // MARK: Properties

    private var networkClientMock: NetworkClientMock!
    private var sut: ExternalAPIClient!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        networkClientMock = NetworkClientMock()
        sut = ExternalAPIClient(
            networkClient: networkClientMock
        )
    }

    override func tearDown() {
        sut = nil
        networkClientMock = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatNetworkClientPerformsRequest_success() throws {
        // given
        let dateString = "2022-01-31T08:42:07Z"
        let date = formatDate(dateString)
        let dateStringObject = DateStringObject(date: dateString)

        let data = try JSONEncoder().encode(dateStringObject)

        networkClientMock.performRequestMethodStub = { _, completion in
            completion(.success(.stub(data: data)))
            return CancellableMock()
        }

        // when
        var result: Result<DateObject, Error>?
        _ = sut.perform(NetworkRequestStub(), completion: { result = $0 })

        // then

        if case let .success(object) = result {
            XCTAssertEqual(date, object.date)
        } else {
            XCTFail()
        }
    }

    func test_thatNetworkClientPerformsRequest_throwAnError() throws {
        // given
        let dateString = "2022"
        let dateStringObject = DateStringObject(date: dateString)

        let data = try JSONEncoder().encode(dateStringObject)

        networkClientMock.performRequestMethodStub = { _, completion in
            completion(.success(.stub(data: data)))
            return CancellableMock()
        }

        // when
        var result: Result<DateObject, Error>?
        _ = sut.perform(NetworkRequestStub(), completion: { result = $0 })

        // then
        if case .success = result {
            XCTFail()
        }
    }

    func test_thatNetworkClientPerformsRequest_failed() throws {
        // given
        networkClientMock.performRequestMethodStub = { _, completion in
            completion(.failure(.emptyResponse))
            return CancellableMock()
        }

        // when
        var result: Result<DateObject, Error>?
        _ = sut.perform(NetworkRequestStub(), completion: { result = $0 })

        // then

        if case let .failure(error) = result {
            XCTAssertEqual(error as NSError, NetworkError.emptyResponse as NSError)
        } else {
            XCTFail()
        }
    }

    // MARK: Private

    private func formatDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
        ]
        return formatter.date(from: string)
    }
}

private extension ExternalAPIClientTests {
    struct DateStringObject: Encodable, Equatable {
        let date: String

        init(date: String) {
            self.date = date
        }
    }

    struct DateObject: Decodable, Equatable {
        let date: Date

        init(date: Date) {
            self.date = date
        }
    }
}
