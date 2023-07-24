import XCTest

public extension XCUIElement {

    /// Скроллим пока элемент не появится
    func scrollToElement(element: XCUIElement) {
        for _ in 0 ... 5 {
            if element.visible() {
                break
            }
            swipeUp()
        }
    }

    /// Проверяем виден ли элемент
    func visible() -> Bool {
        guard exists, !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}
