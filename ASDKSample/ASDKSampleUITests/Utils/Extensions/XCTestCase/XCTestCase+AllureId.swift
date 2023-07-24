import UITestUtils
import XCTest

extension XCTestCase {
    @discardableResult
    func allureId(_ value: Int) -> XCTest {
        return allureId(String(value))
    }
}
