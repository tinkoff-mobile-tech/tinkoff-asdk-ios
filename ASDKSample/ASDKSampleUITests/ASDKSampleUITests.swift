import Nimble
import SwiftyJSON
import TinkoffMockStrapping
import UITestUtils
import XCTest

final class ASDKSampleUITests: BaseUITest {

    // MARK: SetUp & TearDown

    override func setUp() {
        super.setUp()
        setStub(NetworkStub.getCardList.default)
    }

    // MARK: Tests

    func testStubsHistoryOneRequest() {
        XCUIApplication().buttons["💳"].tap()

        expect(self.network.requestsHistory.count).to(equal(1))
        expect(self.network.history.count).to(equal(1))
    }
}
