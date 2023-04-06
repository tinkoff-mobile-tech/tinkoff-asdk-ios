//
//  UIViewControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import UIKit

final class UIViewControllerMock: UIViewController {

    // MARK: - present

    typealias PresentArguments = (
        viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    )

    var presentCallCount = 0
    var presentArguments: PresentArguments?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCallCount += 1

        let arguments = PresentArguments(viewControllerToPresent, flag, completion)
        presentArguments = arguments
    }
}
