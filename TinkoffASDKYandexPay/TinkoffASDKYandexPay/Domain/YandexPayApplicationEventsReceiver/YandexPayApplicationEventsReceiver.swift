//
//  YandexPayApplicationEventsReceiver.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 10.12.2022.
//

import Foundation

public enum YandexPayApplicationEventsReceiver {
    internal static var module: IApplicationEventsReceiver = EventsModule(yandexPayFacade: YandexPaySDKFacade())

    public static func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) {
        module.applicationDidReceiveUserActivity(userActivity)
    }

    public static func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) {
        module.applicationDidReceiveOpen(url, sourceApplication: sourceApplication)
    }

    public static func applicationWillEnterForeground() {
        module.applicationWillEnterForeground()
    }

    public static func applicationDidBecomeActive() {
        module.applicationDidBecomeActive()
    }
}

final class EventsModule: IApplicationEventsReceiver {
    private let yandexPayFacade: IApplicationEventsReceiver & IYandexPaySDKInitializable

    init(yandexPayFacade: IApplicationEventsReceiver & IYandexPaySDKInitializable) {
        self.yandexPayFacade = yandexPayFacade
    }

    func applicationWillEnterForeground() {
        guard yandexPayFacade.isInitialized else { return }
        yandexPayFacade.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive() {
        guard yandexPayFacade.isInitialized else { return }
        yandexPayFacade.applicationDidBecomeActive()
    }

    func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) {
        guard yandexPayFacade.isInitialized else { return }
        yandexPayFacade.applicationDidReceiveOpen(url, sourceApplication: sourceApplication)
    }

    func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) {
        guard yandexPayFacade.isInitialized else { return }
        yandexPayFacade.applicationDidReceiveUserActivity(userActivity)
    }
}
