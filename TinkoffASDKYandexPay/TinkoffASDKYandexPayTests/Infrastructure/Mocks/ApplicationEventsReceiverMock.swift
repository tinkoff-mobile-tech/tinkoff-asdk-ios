//
//  ApplicationEventsReceiverMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 02.06.2023.
//

@testable import TinkoffASDKYandexPay

final class ApplicationEventsReceiverMock: IApplicationEventsReceiver {

    // MARK: - applicationWillEnterForeground

    var applicationWillEnterForegroundCallsCount = 0

    func applicationWillEnterForeground() {
        applicationWillEnterForegroundCallsCount += 1
    }

    // MARK: - applicationDidBecomeActive

    var applicationDidBecomeActiveCallsCount = 0

    func applicationDidBecomeActive() {
        applicationDidBecomeActiveCallsCount += 1
    }

    // MARK: - applicationDidReceiveOpen

    typealias ApplicationDidReceiveOpenArguments = (url: URL, sourceApplication: String?)

    var applicationDidReceiveOpenCallsCount = 0
    var applicationDidReceiveOpenReceivedArguments: ApplicationDidReceiveOpenArguments?
    var applicationDidReceiveOpenReceivedInvocations: [ApplicationDidReceiveOpenArguments] = []

    func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) {
        applicationDidReceiveOpenCallsCount += 1
        let arguments = (url, sourceApplication)
        applicationDidReceiveOpenReceivedArguments = arguments
        applicationDidReceiveOpenReceivedInvocations.append(arguments)
    }

    // MARK: - applicationDidReceiveUserActivity

    var applicationDidReceiveUserActivityCallsCount = 0
    var applicationDidReceiveUserActivityReceivedArguments: NSUserActivity?
    var applicationDidReceiveUserActivityReceivedInvocations: [NSUserActivity] = []

    func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) {
        applicationDidReceiveUserActivityCallsCount += 1
        let arguments = userActivity
        applicationDidReceiveUserActivityReceivedArguments = arguments
        applicationDidReceiveUserActivityReceivedInvocations.append(arguments)
    }
}
