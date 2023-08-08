import Nimble
import SwiftyJSON
import TinkoffMockStrapping
import UITestUtils
import XCTest

final class ASDKSampleUITests: BaseUITest {

    // MARK: SetUp

    override func setUp() {
        super.setUp()
        setStubs(
            NetworkStub.getCardList.default,
            NetworkStub.addCard.default,
            NetworkStub.attachCard.default,
            NetworkStub.getAddCardState.default
        )
    }

    // MARK: Tests

    func testAddNon3dsCard() {
        SampleMainPage().tapOnCardListButton()
        CardListPage().tapOnAddNewCardButton()

        setStub(NetworkStub.getCardList.default) {
            $0.addCard(JSON(["CardId": "3750", "Pan": "220138******0047", "Status": "A", "RebillId": "145119"]))
        }

        AddNewCardPage().apply {
            $0.checkCardNumber()
            $0.checkCardIcon(bank: "empty", paymentSystem: "empty")
            $0.checkExpireDate()
            $0.checkCvc()
            $0.checkAddCardButtonIsDisabled()

            $0.enterCardNumber("2201 3820 0000 0047")
            $0.enterExpireDate(mounth: "03", year: "99")
            $0.enterCVC("123")
            $0.checkAddCardButtonIsEnabled()

            $0.tapOnAddCardButton()
        }

        expect(self.network.requestsHistory.count).to(equal(1))
    }
}
