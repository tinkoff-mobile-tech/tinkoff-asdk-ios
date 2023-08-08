import Foundation

class SampleMainPage: BasePage {

    private lazy var cardListButton = app.buttons["💳"]

    func tapOnCardListButton() {
        cardListButton.waitAndTap()
    }
}
