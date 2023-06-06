//
//  YandexPayApplicationEventsReceiverTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

@testable import TinkoffASDKYandexPay
import XCTest

final class YandexPayApplicationEventsReceiverTests: BaseTestCase {

    var applicationEventsReceiverMock: ApplicationEventsReceiverMock!

    override func setUp() {
        super.setUp()
        applicationEventsReceiverMock = ApplicationEventsReceiverMock()
        YandexPayApplicationEventsReceiver.module = applicationEventsReceiverMock
    }

    override func tearDown() {
        super.tearDown()
        applicationEventsReceiverMock = nil
    }

    func test_applicationDidBecomeActive() {
        // when
        YandexPayApplicationEventsReceiver.applicationDidBecomeActive()
        // then
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidBecomeActiveCallsCount, 1)
    }

    func test_applicationDidReceiveOpen() {
        let source = "sample"
        // when
        YandexPayApplicationEventsReceiver.applicationDidReceiveOpen(.doesNotMatter, sourceApplication: source)
        // then
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidReceiveOpenCallsCount, 1)
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidReceiveOpenReceivedArguments?.url, .doesNotMatter)
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidReceiveOpenReceivedArguments?.sourceApplication, source)
    }

    func test_applicationWillEnterForeground() {
        // when
        YandexPayApplicationEventsReceiver.applicationWillEnterForeground()
        // then
        XCTAssertEqual(applicationEventsReceiverMock.applicationWillEnterForegroundCallsCount, 1)
    }

    func test_applicationDidReceiveUserActivity() {
        let activity: NSUserActivity = .init(activityType: "some")
        // when
        YandexPayApplicationEventsReceiver.applicationDidReceiveUserActivity(activity)
        // then
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidReceiveUserActivityCallsCount, 1)
        XCTAssertEqual(applicationEventsReceiverMock.applicationDidReceiveUserActivityReceivedArguments, activity)
    }
}
