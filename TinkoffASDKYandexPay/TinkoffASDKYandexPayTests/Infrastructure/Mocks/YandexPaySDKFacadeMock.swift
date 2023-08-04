//
//  YandexPaySDKFacadeMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 23.05.2023.
//

@testable import TinkoffASDKYandexPay
import YandexPaySDK

final class YandexPaySDKFacadeMock: IYandexPaySDKFacade {

    var isInitialized: Bool {
        get { return underlyingIsInitialized }
        set(value) { underlyingIsInitialized = value }
    }

    var underlyingIsInitialized: Bool!

    // MARK: - initialize

    typealias InitializeArguments = YandexPaySDK.YandexPaySDKConfiguration

    var initializeThrowableError: Error?
    var initializeCallsCount = 0
    var initializeReceivedArguments: InitializeArguments?
    var initializeReceivedInvocations: [InitializeArguments?] = []

    func initialize(configuration: YandexPaySDK.YandexPaySDKConfiguration) throws {
        if let error = initializeThrowableError {
            throw error
        }
        initializeCallsCount += 1
        let arguments = configuration
        initializeReceivedArguments = arguments
        initializeReceivedInvocations.append(arguments)
    }

    // MARK: - createButton

    typealias CreateButtonArguments = (configuration: YandexPaySDK.YandexPayButtonConfiguration, asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate)

    var createButtonCallsCount = 0
    var createButtonReceivedArguments: CreateButtonArguments?
    var createButtonReceivedInvocations: [CreateButtonArguments?] = []
    var createButtonReturnValue: YandexPaySDK.YandexPayButton!

    func createButton(configuration: YandexPaySDK.YandexPayButtonConfiguration, asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate) -> YandexPaySDK.YandexPayButton {
        createButtonCallsCount += 1
        let arguments = (configuration, asyncDelegate)
        createButtonReceivedArguments = arguments
        createButtonReceivedInvocations.append(arguments)
        return createButtonReturnValue
    }

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
    var applicationDidReceiveOpenReceivedInvocations: [ApplicationDidReceiveOpenArguments?] = []

    func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) {
        applicationDidReceiveOpenCallsCount += 1
        let arguments = (url, sourceApplication)
        applicationDidReceiveOpenReceivedArguments = arguments
        applicationDidReceiveOpenReceivedInvocations.append(arguments)
    }

    // MARK: - applicationDidReceiveUserActivity

    typealias ApplicationDidReceiveUserActivityArguments = NSUserActivity

    var applicationDidReceiveUserActivityCallsCount = 0
    var applicationDidReceiveUserActivityReceivedArguments: ApplicationDidReceiveUserActivityArguments?
    var applicationDidReceiveUserActivityReceivedInvocations: [ApplicationDidReceiveUserActivityArguments?] = []

    func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) {
        applicationDidReceiveUserActivityCallsCount += 1
        let arguments = userActivity
        applicationDidReceiveUserActivityReceivedArguments = arguments
        applicationDidReceiveUserActivityReceivedInvocations.append(arguments)
    }
}

extension YandexPaySDKFacadeMock {
    func fullReset() {
        initializeThrowableError = nil
        initializeCallsCount = 0
        initializeReceivedArguments = nil
        initializeReceivedInvocations = []

        createButtonCallsCount = 0
        createButtonReceivedArguments = nil
        createButtonReceivedInvocations = []

        applicationWillEnterForegroundCallsCount = 0

        applicationDidBecomeActiveCallsCount = 0

        applicationDidReceiveOpenCallsCount = 0
        applicationDidReceiveOpenReceivedArguments = nil
        applicationDidReceiveOpenReceivedInvocations = []

        applicationDidReceiveUserActivityCallsCount = 0
        applicationDidReceiveUserActivityReceivedArguments = nil
        applicationDidReceiveUserActivityReceivedInvocations = []
    }
}
