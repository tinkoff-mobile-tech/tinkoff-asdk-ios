import Foundation
import XCTest

class AddNewCardPage: BasePage {

    // MARK: - Elements

    // Номер карты
    private lazy var cardNumber = app.otherElements[".cardNumber"]
    private lazy var cardNumberTextField = cardNumber.textFields.firstMatch
    private lazy var cardNumberHeaderLabel = cardNumber.staticTexts["headerLabel"]
    private lazy var scanCardButton = cardNumber.buttons["scan card"]

    // Иконка карты
    private lazy var cardIcon = app.otherElements["dynamicCardView"]
    private lazy var bankIcon = cardIcon.images["bankIcon"]
    private lazy var paymentSystemIcon = cardIcon.otherElements["paymentSystemIcon"]

    // Срок
    private lazy var expireDate = app.otherElements[".expireTextField"]
    private lazy var expireDateTextField = expireDate.textFields.firstMatch
    private lazy var expireDateHeaderLabel = expireDate.staticTexts["headerLabel"]

    // CVC
    private lazy var cvc = app.otherElements[".cvcTextField"]
    private lazy var cvcTextField = cvc.secureTextFields.firstMatch
    private lazy var cvcHeaderLabel = cvc.staticTexts["headerLabel"]

    private lazy var addCardButton = app.otherElements["addButton"]
    private lazy var addCardButtonOthers = addCardButton.otherElements.containing(.staticText, identifier: "Добавить").firstMatch

    // MARK: - Actions

    func checkCardNumber() {
        XCTAssertTrue(cardNumberTextField.waitSafely())
        XCTAssertTrue(cardNumberHeaderLabel.exists)
        XCTAssertTrue(scanCardButton.exists)
        XCTAssertEqual("Номер", cardNumberHeaderLabel.label)
    }

    func checkCardIcon(bank: String, paymentSystem: String) {
        XCTAssertTrue(bankIcon.waitSafely())
        XCTAssertTrue(paymentSystemIcon.exists)
        XCTAssertEqual(bank, bankIcon.label)
        XCTAssertEqual(paymentSystem, paymentSystemIcon.label)
    }

    func checkExpireDate() {
        XCTAssertTrue(expireDateTextField.waitSafely())
        XCTAssertTrue(expireDateHeaderLabel.exists)
        XCTAssertEqual("Срок", expireDateHeaderLabel.label)
    }

    func checkCvc() {
        XCTAssertTrue(cvcTextField.waitSafely())
        XCTAssertEqual("CVC", cvcHeaderLabel.label)
    }

    func checkAddCardButtonIsDisabled() {
        XCTAssertFalse(addCardButtonOthers.isEnabled)
    }

    func checkAddCardButtonIsEnabled() {
        XCTAssertTrue(addCardButtonOthers.isEnabled)
    }

    func enterCardNumber(_ number: String) {
        cardNumberTextField.waitSafelyAndTap()
        cardNumberTextField.typeText(number)
    }

    func enterExpireDate(mounth: String, year: String) {
        expireDateTextField.waitSafelyAndTap()
        expireDateTextField.typeText(mounth + year)
        XCTAssertEqual("\(mounth)/\(year)", expireDateTextField.value as? String)
    }

    func enterCVC(_ cvc: String) {
        cvcTextField.waitSafelyAndTap()
        cvcTextField.typeText(cvc)
    }

    func tapOnAddCardButton() {
        addCardButton.waitSafelyAndTap()
    }
}
