//
//  FadingLabel.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.12.2022.
//

open class FadingLabel: UILabel {

    private let fadingMask = FadingTextLayer()

    override open var text: String? {
        didSet {
            updateFadingMask()
        }
    }

    override open var attributedText: NSAttributedString? {
        didSet {
            updateFadingMask()
        }
    }

    override open var numberOfLines: Int {
        didSet {
            updateFadingMask()
        }
    }

    override open var font: UIFont! {
        didSet {
            updateFadingMask()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateFadingMask()
    }

    private func updateFadingMask() {
        if isTextFitsBounds() {
            layer.mask = nil
        } else {
            fadingMask.frame = rectForText()
            fadingMask.update(fontLineHight: minimumAdjustedFont.lineHeight, numberOfLines: numberOfLines)
            layer.mask = fadingMask
        }
    }
}
