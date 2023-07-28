//
//  DispatchQueueTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

@testable import TinkoffASDKYandexPay
import XCTest

final class DispatchQueueTests: BaseTestCase {

    func test_performOnMain_when_started_from_main_queue() {
        // given
        let mainQueue = DispatchQueue.main
        var ranOnMainThread = false
        let expectation = expectation(description: #function)
        // when
        mainQueue.async {
            DispatchQueue.performOnMain {
                ranOnMainThread = Thread.isMainThread
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.2)
        // then
        XCTAssertTrue(ranOnMainThread)
    }

    func test_performOnMain_when_started_from_global_queue() {
        // given
        let globalQueue = DispatchQueue.global()
        var ranOnMainThread = false
        let expectation = expectation(description: #function)
        // when
        globalQueue.async {
            DispatchQueue.performOnMain {
                ranOnMainThread = Thread.isMainThread
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.2)
        // then
        XCTAssertTrue(ranOnMainThread)
    }
}
