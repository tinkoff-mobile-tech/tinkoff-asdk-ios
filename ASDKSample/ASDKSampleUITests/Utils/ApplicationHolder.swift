import Foundation
import XCTest

public final class ApplicationHolder {

    public static let shared = ApplicationHolder(
        application: XCUIApplication(),
        springboard: XCUIApplication(bundleIdentifier: "com.apple.springboard")
    )

    public let application: XCUIApplication
    public let springboard: XCUIApplication

    private init(application: XCUIApplication, springboard: XCUIApplication) {
        self.application = application
        self.springboard = springboard
    }
}
