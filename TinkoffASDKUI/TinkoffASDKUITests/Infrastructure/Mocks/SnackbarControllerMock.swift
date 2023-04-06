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
    var showSnackViewCallArguments: ShowSnackViewArguments?
    var showSnackViewsShouldRunCompletion = true

    func showSnackView(
        config: SnackbarView.Configuration,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        showSnackViewCallsCount += 1
        showSnackViewCallArguments = (config, animated, completion)
        if showSnackViewsShouldRunCompletion { completion?(true) }
    }

    // MARK: - hideSnackView

    typealias HideSnackViewArguments = (animated: Bool, completion: ((Bool) -> Void)?)

    var hideSnackViewCallsCount = 0
    var hideSnackViewCallArguments: HideSnackViewArguments?
    var hideSnackViewShouldRunCompletion = true

    func hideSnackView(animated: Bool, completion: ((Bool) -> Void)?) {
        hideSnackViewCallsCount += 1
        hideSnackViewCallArguments = (animated, completion)
        if hideSnackViewShouldRunCompletion { completion?(true) }
    }
}
