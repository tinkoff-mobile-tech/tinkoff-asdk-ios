import Nimble
import SwiftyJSON
import TinkoffMockStrapping
import UITestUtils
import XCTest

final class ASDKSampleUITests: BaseUITest {

    private var port: UInt16!

    private var json: JSON {
        return ["CardId": "528358165", "Pan": "220138******0260", "Status": "A", "RebillId": "", "CardType": 0, "ExpDate": "1111"]
    }

    private var json2: JSON {

        return JSON()
    }

    // MARK: SetUp & TearDown

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testStubsHistoryOneRequest() {
        let url = "v2/GetCardList"
        let query = ["query1": "1", "query2": "2"]
        let excludedQuery = ["query3": "3"]
        let request = NetworkStubRequest(
            url: url,
            excludedQuery: excludedQuery,
            httpMethod: .GET
        )
        let response = NetworkStubResponse.json(json)
        let stub = NetworkStub(request: request, response: response)
        server!.setStub(stub)

        XCUIApplication().buttons["💳"].tap()
        expect(self.server!.requestsHistory.count).to(equal(1))
        expect(self.server!.history.count).to(equal(1))
        expect(self.server!.requestsHistory[0].url).to(contain(url))

        repeat {} while true
    }

    func testExample() throws {
        var mockServer = MockNetworkServer()
        var port = mockServer.start()
        print("Hello tests!")

        let url = "https://rest-api-test.tinkoff.ru/v2/GetTerminalPayMethods?TerminalKey=TestSDK&PaySource=SDK"
        let stubRequest = NetworkStubRequest(url: url, httpMethod: .GET)
        let stubResponse = NetworkStubResponse.json(JSON(rawValue: "")!)
        let stub = NetworkStub(request: stubRequest, response: stubResponse)
        mockServer.setStub(stub)

        repeat {} while true
    }
}
