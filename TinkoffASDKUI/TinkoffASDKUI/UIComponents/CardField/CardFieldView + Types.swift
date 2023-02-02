import UIKit

extension CardFieldView {

    struct DataDependecies {
        let dynamicCardIconData: DynamicIconCardView.Data

        let expirationTextFieldData: TextFieldData
        let cardNumberTextFieldData: TextFieldData
        let cvcTextFieldData: TextFieldData

        struct TextFieldData {
            let delegate: FloatingTextFieldDelegate?
            let text: String?
        }
    }
}
