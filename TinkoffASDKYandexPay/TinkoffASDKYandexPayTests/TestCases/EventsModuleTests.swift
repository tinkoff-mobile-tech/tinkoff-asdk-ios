//
//  EventsModuleTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

@testable import TinkoffASDKYandexPay
import XCTest

final class EventsModuleTests: BaseTestCase {

    var sut: EventsModule!

    // Mocks

    var yandexPaySDKFacadeMock: YandexPaySDKFacadeMock!

    override func setUp() {
        super.setUp()
        yandexPaySDKFacadeMock = YandexPaySDKFacadeMock()
        sut = EventsModule(yandexPayFacade: yandexPaySDKFacadeMock)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        yandexPaySDKFacadeMock = nil
    }

    func test_applicationDidReceiveUserActivity() {
        // given
        yandexPaySDKFacadeMock.isInitialized = true
        let activity = NSUserActivity(activityType: "some-activity")
        // when
        sut.applicationDidReceiveUserActivity(activity)
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveUserActivityCallsCount, 1)
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveUserActivityReceivedArguments, activity)
    }

    func test_applicationDidReceiveOpen() {
        // given
        yandexPaySDKFacadeMock.isInitialized = true
        let source = "sample"
        // when
        sut.applicationDidReceiveOpen(.doesNotMatter, sourceApplication: source)
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveOpenCallsCount, 1)
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveOpenReceivedArguments?.url, .doesNotMatter)
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveOpenReceivedArguments?.sourceApplication, source)
    }

    func test_applicationWillEnterForeground() {
        yandexPaySDKFacadeMock.isInitialized = true
        // when
        sut.applicationWillEnterForeground()
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationWillEnterForegroundCallsCount, 1)
    }

    func test_applicationDidBecomeActive() {
        // given
        yandexPaySDKFacadeMock.isInitialized = true
        // when
        sut.applicationDidBecomeActive()
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidBecomeActiveCallsCount, 1)
    }

    func test_applicationDidReceiveUserActivity_when_notInitialized() {
        yandexPaySDKFacadeMock.isInitialized = false
        let activity = NSUserActivity(activityType: "some-activity")
        // when
        sut.applicationDidReceiveUserActivity(activity)
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveUserActivityCallsCount, .zero)
    }

    func test_applicationDidReceiveOpen_when_notInitialized() {
        // given
        yandexPaySDKFacadeMock.isInitialized = false
        // when
        sut.applicationDidReceiveOpen(.doesNotMatter, sourceApplication: "sourcer")
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidReceiveOpenCallsCount, .zero)
    }

    func test_applicationWillEnterForeground_when_notInitialized() {
        // given
        yandexPaySDKFacadeMock.isInitialized = false
        // when
        sut.applicationWillEnterForeground()
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationWillEnterForegroundCallsCount, .zero)
    }

    func test_applicationDidBecomeActive_when_notInitialized() {
        // given
        yandexPaySDKFacadeMock.isInitialized = false
        // when
        sut.applicationDidBecomeActive()
        // then
        XCTAssertEqual(yandexPaySDKFacadeMock.applicationDidBecomeActiveCallsCount, .zero)
    }
}
