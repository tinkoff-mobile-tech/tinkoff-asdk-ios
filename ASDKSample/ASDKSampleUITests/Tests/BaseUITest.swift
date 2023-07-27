import SwiftyJSON
import TinkoffMockStrapping
import XCTest

open class BaseUITest: XCTestCase {

    var server: MockNetworkServer?
    lazy var app: XCUIApplication = ApplicationHolder.shared.application

    override open func setUp() {
        super.setUp()
        server = MockNetworkServer()
        let port = server!.start()

        app.launchEnvironment["TEST"] = "1"
        app.launchEnvironment["MOCK_SERVER_PORT"] = String(describing: port)
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
