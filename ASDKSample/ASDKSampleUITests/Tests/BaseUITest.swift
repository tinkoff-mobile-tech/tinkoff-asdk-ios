//
//  BaseUITest.swift
//  UITests
//
//  Created by Glushkov Gleb on 21.07.2023.
//

import XCTest

open class BaseUITest: XCTestCase {

    lazy var app: XCUIApplication = ApplicationHolder.shared.application

    override open func setUp() {
        super.setUp()
        app.launch()
    }

    override open func tearDown() {
        super.tearDown()
        addScreenshot()
    }

    override open func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func addScreenshot() {
        XCTest().step("Добавляем кастомный скриншот") {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(image: screenshot.image)
            attachment.name = "Custom_Screenshot_"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}
