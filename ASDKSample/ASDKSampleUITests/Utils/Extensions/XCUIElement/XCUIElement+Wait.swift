//
//  XCUIElement+Wait.swift
//  UITests
//
//  Created by Andrey Belyaev on 10.10.2022.
//

import XCTest

public extension XCUIElement {

    func waitAndTap(timeout: TimeInterval = 60) {
        wait(timeout: timeout)
        tap()
    }

    func waitSafelyAndTap(timeout: TimeInterval = 5) {
        if waitSafely(timeout: timeout) {
            tap()
        }
    }

    func waitSafely(for state: WaitType = .exists) -> Bool {
        waitSafely(for: state, timeout: .defaultTimeout)
    }
}
