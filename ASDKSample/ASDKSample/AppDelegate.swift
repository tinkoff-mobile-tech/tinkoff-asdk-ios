//
//  AppDelegate.swift
//  ASDKSample
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKYandexPay
import UIKit
import YandexPaySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        YandexPayApplicationEventsReceiver.applicationDidReceiveUserActivity(userActivity)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        YandexPayApplicationEventsReceiver.applicationDidReceiveOpen(url, sourceApplication: options[.sourceApplication] as? String)
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        YandexPayApplicationEventsReceiver.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        YandexPayApplicationEventsReceiver.applicationDidBecomeActive()
    }
}
