//
//  FadingTextLayer.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.12.2022.
//

public final class FadingTextLayer: CALayer {

    private let gradientMaskLayer = CAGradientLayer()
    private let fullLinesMaskLayer = CALayer()

    override public init() {
        super.init()
        commonInit()
    }

    override public init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        gradientMaskLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientMaskLayer.colors = [
            UIColor(white: 0, alpha: 1).cgColor,
            UIColor(white: 0, alpha: 0).cgColor,
        ]
        addSublayer(gradientMaskLayer)

        fullLinesMaskLayer.backgroundColor = UIColor.black.cgColor
        fullLinesMaskLayer.isHidden = true
        addSublayer(fullLinesMaskLayer)
    }

    public func update(fontLineHight: CGFloat, numberOfLines: Int) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        let fadeMaskWidth = fontLineHight * maskWidthRelativeFontHeight
        let start = (bounds.width - fadeMaskWidth) / bounds.width
        gradientMaskLayer.startPoint = CGPoint(x: start, y: 0)
        gradientMaskLayer.frame = bounds

        let needFullLinesMask = numberOfLines != 1
        fullLinesMaskLayer.isHidden = !needFullLinesMask
        if needFullLinesMask {
            fullLinesMaskLayer.frame = bounds
            fullLinesMaskLayer.frame.size.height -= fontLineHight
        }

        CATransaction.commit()
    }
}

private let maskWidthRelativeFontHeight: CGFloat = 1.5
