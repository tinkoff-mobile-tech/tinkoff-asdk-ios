//
//  SnackbarControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 24.03.2023
//

@testable import TinkoffASDKUI
import UIKit

final class SnackbarControllerMock: ISnackbarController {

    // MARK: - showSnackView

    typealias ShowSnackViewArguments = (config: SnackbarView.Configuration, animated: Bool, completion: ((Bool) -> Void)?)

    var showSnackViewCallsCount = 0
    var showSnackViewReceivedArguments: ShowSnackViewArguments?
    var showSnackViewReceivedInvocations: [ShowSnackViewArguments?] = []
    var showSnackViewCompletionClosureInput: Bool? = true

    func showSnackView(config: SnackbarView.Configuration, animated: Bool, completion: ((Bool) -> Void)?) {
        showSnackViewCallsCount += 1
        let arguments = (config, animated, completion)
        showSnackViewReceivedArguments = arguments
        showSnackViewReceivedInvocations.append(arguments)
        if let showSnackViewCompletionClosureInput = showSnackViewCompletionClosureInput {
            completion?(showSnackViewCompletionClosureInput)
        }
    }

    // MARK: - hideSnackView

    typealias HideSnackViewArguments = (animated: Bool, completion: ((Bool) -> Void)?)

    var hideSnackViewCallsCount = 0
    var hideSnackViewReceivedArguments: HideSnackViewArguments?
    var hideSnackViewReceivedInvocations: [HideSnackViewArguments?] = []
    var hideSnackViewCompletionClosureInput: Bool? = true

    func hideSnackView(animated: Bool, completion: ((Bool) -> Void)?) {
        hideSnackViewCallsCount += 1
        let arguments = (animated, completion)
        hideSnackViewReceivedArguments = arguments
        hideSnackViewReceivedInvocations.append(arguments)
        if let hideSnackViewCompletionClosureInput = hideSnackViewCompletionClosureInput {
            completion?(hideSnackViewCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension SnackbarControllerMock {
    func fullReset() {
        showSnackViewCallsCount = 0
        showSnackViewReceivedArguments = nil
        showSnackViewReceivedInvocations = []
        showSnackViewCompletionClosureInput = nil

        hideSnackViewCallsCount = 0
        hideSnackViewReceivedArguments = nil
        hideSnackViewReceivedInvocations = []
        hideSnackViewCompletionClosureInput = nil
    }
}
