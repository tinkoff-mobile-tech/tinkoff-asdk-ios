//
//  FadingLabel.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.12.2022.
//

class FadingLabel: UILabel {

    private let fadingMask = FadingTextLayer()

    override var text: String? {
        didSet {
            updateFadingMask()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            updateFadingMask()
        }
    }

    override var numberOfLines: Int {
        didSet {
            updateFadingMask()
        }
    }

    override var font: UIFont! {
        didSet {
            updateFadingMask()
        }
    }

    override func layoutSubviews() {
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
