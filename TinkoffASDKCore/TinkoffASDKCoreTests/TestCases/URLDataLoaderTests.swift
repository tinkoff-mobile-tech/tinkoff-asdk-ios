//
//  URLDataLoaderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 18.07.2023.
//

@testable import TinkoffASDKCore
import XCTest

final class URLDataLoaderTests: XCTestCase {
    // MARK: Properties

    private var networkClientMock: NetworkClientMock!
    private var sut: URLDataLoader!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        networkClientMock = NetworkClientMock()
        sut = URLDataLoader(networkClient: networkClientMock)
    }

    override func tearDown() {
        networkClientMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_loadData_success() {
        // given
        let data = Data()
        networkClientMock.performRequestURLRequestMethodStub = { _, completion -> Cancellable in
            completion(.success(.stub(data: data)))
            return CancellableMock()
        }

        // when
        var result: Result<Data, Error>?
        sut.loadData(with: .doesNotMatter) { result = $0 }

        // then
        if case let .success(response) = result {
            XCTAssertEqual(response, data)
        } else {
            XCTFail()
        }
    }

    func test_loadData_failed() {
        // given
        let errorMock = NetworkError.emptyResponse
        networkClientMock.performRequestURLRequestMethodStub = { _, completion -> Cancellable in
            completion(.failure(errorMock))
            return CancellableMock()
        }

        // when
        var result: Result<Data, Error>?
        sut.loadData(with: .doesNotMatter) { result = $0 }

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(error as NSError, errorMock as NSError)
        } else {
            XCTFail()
        }
    }
}
