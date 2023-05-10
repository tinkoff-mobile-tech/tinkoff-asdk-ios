//
//  YandexPayButtonMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

import UIKit
import YandexPaySDK

final class YandexPayButtonMock: UIView, YandexPayButton {

    init() { super.init(frame: .zero) }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Properties

    var theme: YandexPaySDK.YandexPayButtonTheme {
        get { return underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: YandexPaySDK.YandexPayButtonTheme!

    // MARK: - setTheme

    typealias SetThemeArguments = (theme: YandexPaySDK.YandexPayButtonTheme, animated: Bool)

    var setThemeCallsCount = 0
    var setThemeReceivedArguments: SetThemeArguments?
    var setThemeReceivedInvocations: [SetThemeArguments] = []

    func setTheme(_ theme: YandexPaySDK.YandexPayButtonTheme, animated: Bool) {
        setThemeCallsCount += 1
        let arguments = (theme, animated)
        setThemeReceivedArguments = arguments
        setThemeReceivedInvocations.append(arguments)
    }

    // MARK: - setLoaderVisible

    typealias SetLoaderVisibleArguments = (visible: Bool, animated: Bool)

    var setLoaderVisibleCallsCount = 0
    var setLoaderVisibleReceivedArguments: SetLoaderVisibleArguments?
    var setLoaderVisibleReceivedInvocations: [SetLoaderVisibleArguments] = []

    func setLoaderVisible(_ visible: Bool, animated: Bool) {
        setLoaderVisibleCallsCount += 1
        let arguments = (visible, animated)
        setLoaderVisibleReceivedArguments = arguments
        setLoaderVisibleReceivedInvocations.append(arguments)
    }

    // MARK: - reloadPersonalizationData

    var reloadPersonalizationDataCallsCount = 0
    var reloadPersonalizationDataReceivedArguments: ((Error?) -> Void)?
    var reloadPersonalizationDataReceivedInvocations: [(Error?) -> Void] = []
    var reloadPersonalizationDataCompletionClosureInput: Error??

    func reloadPersonalizationData(completion: @escaping (Error?) -> Void) {
        reloadPersonalizationDataCallsCount += 1
        let arguments = completion
        reloadPersonalizationDataReceivedArguments = arguments
        reloadPersonalizationDataReceivedInvocations.append(arguments)
        if let reloadPersonalizationDataCompletionClosureInput = reloadPersonalizationDataCompletionClosureInput {
            completion(reloadPersonalizationDataCompletionClosureInput)
        }
    }
}
