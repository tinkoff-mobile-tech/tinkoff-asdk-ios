import SwiftyJSON
import TinkoffMockStrapping
import XCTest

open class BaseUITest: XCTestCase, SetStubAvailable {

    public let network = MockNetworkServer()
    let app: XCUIApplication = ApplicationHolder.shared.application

    override open func setUp() {
        super.setUp()

        guard let port = network.start() else {
            XCTFail("Failed to start mock server.")
            return
        }

        app.launchEnvironment[.UITests] = "1"
        app.launchEnvironment[.mockServerUrl] = "http://localhost:\(port)/"
        app.launch()
    }

    override open func tearDown() {
        network.stop()
        addScreenshot()
        super.tearDown()
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

// MARK: - Constants

private extension String {
    static let UITests = "UI_TESTS"
    static let mockServerUrl = "MOCK_SERVER_URL"
}
