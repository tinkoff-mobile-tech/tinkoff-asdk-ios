import UIKit

extension CardFieldView {

    struct Constants {

        struct Card {
            static let height: CGFloat = 56

            struct DynamicIcon {
                static let topInset: CGFloat = 15
                static let leftInset: CGFloat = 12
                static let size = CGSize(width: 40, height: 26)
            }

            struct TextField {
                static let topInset: CGFloat = 9
                static let leftInset: CGFloat = 12
                static let rightInset: CGFloat = 20
            }
        }

        struct Expiration {
            static let topInset: CGFloat = 12
            static let height: CGFloat = 56

            struct TextField {
                static let insets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12)
            }
        }

        struct Cvc {
            static let leftInset: CGFloat = 11
            static let height: CGFloat = 56
            struct TextField {
                static let insets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12)
            }
        }
    }
}
