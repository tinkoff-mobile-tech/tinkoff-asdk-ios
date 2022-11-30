import Foundation

extension CardFieldView {

    struct DataDependecies {
        let cardFieldData: Data
        let dynamicCardIconData: DynamicIconCardView.Data

        let expirationTextFieldData: TextFieldData
        let cardNumberTextFieldData: TextFieldData
        let cvcTextFieldData: TextFieldData

        struct TextFieldData {
            let delegate: UITextFieldDelegate?
            let text: String?
            let placeholder: String?
            let headerText: String
        }
    }
}
