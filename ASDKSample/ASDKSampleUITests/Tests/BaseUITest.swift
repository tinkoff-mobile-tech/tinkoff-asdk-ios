//
//
//  BaseUITest.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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
