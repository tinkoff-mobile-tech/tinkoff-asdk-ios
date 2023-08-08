import Foundation
import XCTest

class BasePage: HasApply {

    lazy var app: XCUIApplication = ApplicationHolder.shared.application
}

protocol HasApply {}

extension HasApply {
    func apply(actions: (Self) -> Void) {
        actions(self)
    }
}
