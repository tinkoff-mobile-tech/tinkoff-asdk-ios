//
//  PopupViewController.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.10.2022.
//

import UIKit

// MARK: - Inner Types

extension PopupViewController {

    struct PopUpStyle {
        var backgroundColor: UIColor = .white
        var cornerRadius: CGFloat = 13
        var topBarHeight: CGFloat = 24
        var iconImageWidth: CGFloat = 32
        var limit = Limit()
    }

    struct Limit {
        var shouldLimitToSafeArea = true
        var topInset: CGFloat = 0
    }

    struct Data {
        let contentView: UIView
        var panBarIndicatorImage: UIImage? = Asset.Icons.popupBar.image
        var contentHeight: CGFloat = 100
        /// between 0 and 1
        var thresholdPercentage: CGFloat = 0.6
        var onBackingViewTap: () -> Void = {}
    }

    struct Model {
        let id = UUID().uuidString
        var style = PopUpStyle()
        let data: Data

        static func getEmpty() -> Model {
            Model(data: PopupViewController.Data(contentView: UIView(), contentHeight: 100))
        }
    }

    enum DragDirection {
        case up
        case down
    }
}

extension PopupViewController.Data {

    init(
        contentViewController: UIViewController,
        panBarIndicatorImage: UIImage?,
        contentHeight: CGFloat,
        thresholdPercentage: CGFloat
    ) {
        self.init(
            contentView: contentViewController.view,
            panBarIndicatorImage: panBarIndicatorImage,
            contentHeight: contentHeight,
            thresholdPercentage: thresholdPercentage
        )
    }
}

// MARK: - PopupViewController

/// Позволяет показывать контент внутри вью которая может быть закрыта
final class PopupViewController: UIViewController {

    weak var delegate: PopupDelegate?

    private let popupView = UIView()
    private let dismissTapGR = UITapGestureRecognizer()
    private let panGR = UIPanGestureRecognizer()
    private let panBackingView = UIView()
    private let panImageView = UIImageView()

    private weak var contentView: UIView? {
        didSet {
            contentView?.removeFromSuperview()
            if let contentView = contentView {
                popupView.addSubview(contentView)
            }
        }
    }

    // State
    private var originalPopupOriginY: CGFloat = 0
    private var beganPopupOriginY: CGFloat = 0
    private var beganYLocationValue: CGFloat = 0
    private var beganTransformTyValue: CGFloat = 0

    private var currentModel: Model = .getEmpty()

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Public

    func configure(model: Model) {
        currentModel = model
        panImageView.image = model.data.panBarIndicatorImage

        makeConstraints(model: model)
        setupPopupView(style: model.style)
        setupPopupView(model: model)
    }

    // MARK: - Private

    @objc private func panAction(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            beganPopupOriginY = popupView.frame.origin.y
            beganYLocationValue = panGR.location(in: view).y
            beganTransformTyValue = popupView.transform.ty

        case .changed:
            panGestureChanged(panGR: panGR)

        case .cancelled, .possible, .failed:
            break

        case .ended:
            panGestureEnded(panGR: panGR, thresholdPercentage: currentModel.data.thresholdPercentage)

        @unknown default:
            break
        }

        calculateFractionComplete()
    }

    private func calculateFractionComplete() {
        var fractionComplete = (popupView.frame.origin.y - getTopLimitPointY()) / (originalPopupOriginY - getTopLimitPointY())
        fractionComplete = 1 - fractionComplete

        if fractionComplete > 0.99 {
            fractionComplete = 1
        } else if fractionComplete < -0.99 {
            fractionComplete = -1
        }

        delegate?.updatedFractionComplete(value: fractionComplete)
    }

    private func panGestureChanged(panGR: UIPanGestureRecognizer) {
        let locationY = panGR.location(in: view).y
        let distanceInPopupViewFromOrigin = beganYLocationValue - beganPopupOriginY
        let topLimitPointY = getTopLimitPointY()

        let maxValue = getTopLimitPointY() + distanceInPopupViewFromOrigin - beganYLocationValue
        let locationInSuperViewAtYOriginPopupView = locationY - distanceInPopupViewFromOrigin

        var transformTyValue = (locationY - beganYLocationValue) + beganTransformTyValue

        if locationInSuperViewAtYOriginPopupView < topLimitPointY {
            transformTyValue = maxValue + beganTransformTyValue
        }

        guard transformTyValue != maxValue + beganTransformTyValue else { return }
        UIView.animate(withDuration: 0.1) {
            self.popupView.transform.ty = transformTyValue
        }
    }

    private func panGestureEnded(panGR: UIPanGestureRecognizer, thresholdPercentage: CGFloat) {
        let velocityYAbsolute = abs(panGR.velocity(in: view).y)
        let limit = view.frame.height * 3
        let isFastVelocity = velocityYAbsolute > limit
        let diffFromStartLocationY = panGR.location(in: view).y - beganYLocationValue
        let dragDirection: DragDirection = diffFromStartLocationY > 0 ? .down : .up

        let limitPoint = dragDirection == .up ? getTopLimitPointY() : getBottomLimitPointY()

        let diff = beganPopupOriginY - limitPoint
        let value = 1 - ((popupView.frame.origin.y - limitPoint) / diff)

        if !isFastVelocity && value < thresholdPercentage {
            // пружиним назад
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.popupView.transform = .identity
                    self.calculateFractionComplete()
                }
            )
        } else {
            // did pass the threshold
            switch dragDirection {
            case .up:
                if isFastVelocity, abs(diff) != 0 {
                    delegate?.willUnfold()
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.popupView.transform.ty = -diff + self.beganTransformTyValue
                        },
                        completion: { [weak self] _ in
                            self?.delegate?.didUnfold()
                        }
                    )
                } else if beganTransformTyValue != popupView.transform.ty {
                    delegate?.didUnfold()
                }

            case .down:
                // folding popupview
                delegate?.willFold()
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        self.popupView.transform.ty = self.popupView.frame.height
                        self.calculateFractionComplete()
                    },
                    completion: { [weak self] _ in
                        self?.delegate?.didFold()
                    }
                )
            }
        }
    }

    @objc private func dismissTapAction(tapGR: UITapGestureRecognizer) {
        let tapLocationY = tapGR.location(in: view).y
        guard tapLocationY < popupView.frame.origin.y else { return }
        currentModel.data.onBackingViewTap()
    }

    private func setupViews() {
        view.addSubview(popupView)
        popupView.addSubview(panBackingView)
        panBackingView.addSubview(panImageView)

        view.backgroundColor = nil
        view.addGestureRecognizer(dismissTapGR)
        popupView.addGestureRecognizer(panGR)
        panGR.maximumNumberOfTouches = 1
        panGR.addTarget(self, action: #selector(panAction(panGR:)))
        dismissTapGR.addTarget(self, action: #selector(dismissTapAction(tapGR:)))
    }

    private func makeConstraints(model: Model) {

        let iconImageWidth: CGFloat = model.style.iconImageWidth

        panBackingView.makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: make.forcedSuperview.topAnchor),
                make.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            ]
                + make.size(CGSize(width: iconImageWidth * 2, height: model.style.topBarHeight))
        }

        panImageView.contentMode = .scaleAspectFit
        panImageView.clipsToBounds = true

        panImageView.makeConstraints { make in
            [
                make.centerXAnchor.constraint(equalTo: panBackingView.centerXAnchor),
                make.centerYAnchor.constraint(equalTo: panBackingView.centerYAnchor),
            ]

                + make.size(CGSize(width: iconImageWidth, height: model.style.topBarHeight))
        }
    }

    private func getMaxPopupHeight() -> CGFloat {
        let topSafeInset = UIWindow.findKeyWindow()?.safeAreaInsets.top ?? 0
        let result = view.frame.height - currentModel.style.limit.topInset
        if currentModel.style.limit.shouldLimitToSafeArea {
            return result - topSafeInset
        }
        return result
    }

    private func getTopLimitPointY() -> CGFloat {
        view.frame.height - getMaxPopupHeight()
    }

    private func getBottomLimitPointY() -> CGFloat {
        let bottomSafeInset = UIWindow.findKeyWindow()?.safeAreaInsets.bottom ?? 0
        if currentModel.style.limit.shouldLimitToSafeArea {
            return view.frame.height - bottomSafeInset
        }
        return view.frame.height
    }

    private func setupPopupView(style: PopUpStyle) {
        popupView.backgroundColor = style.backgroundColor
        popupView.layer.cornerRadius = style.cornerRadius
    }

    private func setupPopupView(model: Model) {
        let data = model.data
        let originalOrigin = view.frame.origin
        let fullPopupHeight = model.style.topBarHeight + data.contentHeight
        let maxPopupHeight = getMaxPopupHeight()
        let height = min(maxPopupHeight, fullPopupHeight)
        let popupOrigin = CGPoint(x: originalOrigin.x, y: view.frame.height - height)
        popupView.frame = CGRect(
            origin: popupOrigin,
            size: CGSize(
                width: view.frame.width,
                height: UIWindow.findKeyWindow()?.screen.bounds.height ?? .zero
            )
        )
        originalPopupOriginY = popupView.frame.origin.y
        contentView = data.contentView

        data.contentView.makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: popupView.topAnchor, constant: model.style.topBarHeight),
                make.leftAnchor.constraint(equalTo: popupView.leftAnchor),
                make.rightAnchor.constraint(equalTo: popupView.rightAnchor),
                make.height(constant: popupView.frame.height),
            ]
        }
    }
}
