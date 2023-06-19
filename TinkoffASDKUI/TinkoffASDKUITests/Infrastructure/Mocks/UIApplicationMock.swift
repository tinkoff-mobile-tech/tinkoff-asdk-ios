//
//  UIApplicationMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class UIApplicationMock: IUIApplication {

    // MARK: - canOpenURL

    var canOpenURLCallsCount = 0
    var canOpenURLReceivedArguments: URL?
    var canOpenURLReceivedInvocations: [URL] = []
    var canOpenURLReturnValue: Bool!

    func canOpenURL(_ url: URL) -> Bool {
        canOpenURLCallsCount += 1
        let arguments = url
        canOpenURLReceivedArguments = arguments
        canOpenURLReceivedInvocations.append(arguments)
        return canOpenURLReturnValue
    }

    // MARK: - open

    typealias OpenArguments = (url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completion: ((Bool) -> Void)?)

    var openCallsCount = 0
    var openReceivedArguments: OpenArguments?
    var openReceivedInvocations: [OpenArguments] = []
    var openCompletionClosureInput: Bool?

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
        openCallsCount += 1
        let arguments = (url, options, completion)
        openReceivedArguments = arguments
        openReceivedInvocations.append(arguments)
        if let openCompletionClosureInput = openCompletionClosureInput {
            completion?(openCompletionClosureInput)
        }
    }
}
