//
//  NSAttributedString+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.12.2022.
//

import UIKit

extension NSAttributedString {
    func fitsIn(size: CGSize, font: UIFont, numberOfLines: Int) -> Bool {
        // lineBreakMode should be byWordWrapping to return multiline height in boundingRect(with size:)
        let text = with(font: font).withLineBreakMode(.byWordWrapping)
        guard text.size().width > size.width else {
            return true
        }

        let attributedTextHeight = text.height(withConstrainedWidth: size.width)

        let linesHeight = numberOfLines == .zero ? ceil(size.height) :
            ceil(min(font.lineHeight * CGFloat(numberOfLines), size.height))

        return attributedTextHeight <= linesHeight
    }

    func with(font newFont: UIFont?) -> NSAttributedString {
        guard
            let mutableAttributedString = mutableCopy() as? NSMutableAttributedString,
            let newFont = newFont
        else {
            return self
        }

        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            if let font = value as? UIFont,
               let newFontDescriptor = font.fontDescriptor
               .withFamily(newFont.familyName)
               .withSymbolicTraits(font.fontDescriptor.symbolicTraits) {

                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: newFont.pointSize
                )

                mutableAttributedString.removeAttribute(.font, range: range)
                mutableAttributedString.addAttribute(.font, value: newFont, range: range)
            }
        }

        return mutableAttributedString
    }

    func withLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> NSAttributedString {
        guard let mutableAttributedString = mutableCopy() as? NSMutableAttributedString else {
            return self
        }

        enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: length)) { value, range, _ in
            let value = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            value.lineBreakMode = lineBreakMode
            mutableAttributedString.removeAttribute(.paragraphStyle, range: range)
            mutableAttributedString.addAttribute(.paragraphStyle, value: value, range: range)
        }

        return NSAttributedString(attributedString: mutableAttributedString)
    }

    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let bounds = boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return ceil(bounds.height)
    }
}
