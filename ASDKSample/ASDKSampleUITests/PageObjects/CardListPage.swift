import Foundation

class CardListPage: BasePage {

    private lazy var addNewCardButton = app.cells.containing(.image, identifier: "cardPlus").firstMatch

    func tapOnAddNewCardButton() {
        addNewCardButton.waitAndTap()
    }
}
