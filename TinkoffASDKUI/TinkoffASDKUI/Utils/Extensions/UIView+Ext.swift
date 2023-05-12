//
//  UIView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.10.2022.
//

import UIKit

// MARK: - UIView + Constraints

extension UIView {

    // MARK: - Properties

    var forcedSuperview: UIView { superview! }

    var parsedConstraints: Set<ParsedConstraint> {
        parseConstraints()
    }

    // MARK: - Methods

    func height(constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: constant
        )
    }

    func width(constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: constant
        )
    }

    func size(_ size: CGSize) -> [NSLayoutConstraint] {
        [
            height(constant: size.height),
            width(constant: size.width),
        ]
    }

    func edgesEqualToSuperview(insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        assert(superview != nil)
        return [
            topAnchor.constraint(equalTo: forcedSuperview.topAnchor, constant: insets.top),
            leftAnchor.constraint(equalTo: forcedSuperview.leftAnchor, constant: insets.left),
            rightAnchor.constraint(equalTo: forcedSuperview.rightAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: forcedSuperview.bottomAnchor, constant: -insets.bottom),
        ]
    }

    func pinLeftTop(size: CGSize) {
        assert(superview != nil)
        makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor),
                view.leftAnchor.constraint(equalTo: view.forcedSuperview.leftAnchor),
            ] + view.size(size)
        }
    }

    func makeLeftAndRightEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint] {
        return [
            leftAnchor.constraint(equalTo: forcedSuperview.leftAnchor, constant: inset),
            rightAnchor.constraint(equalTo: forcedSuperview.rightAnchor, constant: -inset),
        ]
    }

    func makeTopAndBottomEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint] {
        assert(superview != nil)
        return [
            topAnchor.constraint(equalTo: forcedSuperview.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: forcedSuperview.bottomAnchor, constant: -inset),
        ]
    }

    func makeConstraints(_ closure: (_ view: UIView) -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        let madeContraints = closure(self)
        NSLayoutConstraint.activate(madeContraints)
    }

    func makeEqualToSuperview(insets: UIEdgeInsets = .zero) {
        assert(superview != nil)
        makeConstraints { _ in
            edgesEqualToSuperview(insets: insets)
        }
    }

    func makeCenterEqualToSuperview(xOffset: CGFloat = .zero, yOffset: CGFloat = .zero) -> [NSLayoutConstraint] {
        assert(superview != nil)
        return [
            centerXAnchor.constraint(equalTo: forcedSuperview.centerXAnchor, constant: xOffset),
            centerYAnchor.constraint(equalTo: forcedSuperview.centerYAnchor, constant: yOffset),
        ]
    }

    func makeEqualToSuperviewToSafeArea(insets: UIEdgeInsets = .zero) {
        assert(superview != nil)
        makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                make.leftAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.leftAnchor, constant: insets.left),
                make.rightAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.rightAnchor, constant: -insets.right),
                make.bottomAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom),
            ]
        }
    }
}

extension UIView {

    private func parseConstraints() -> Set<ParsedConstraint> {
        let superViewConstraints = forcedSuperview.constraints
        let selfConstraints = constraints.filter {
            $0.firstItem === self && $0.secondItem == nil
        }

        let combinedConstraints = superViewConstraints + selfConstraints

        let array = combinedConstraints.compactMap { nsConstraint -> ParsedConstraint? in
            var properItem: AnyObject?

            if nsConstraint.firstItem === self {
                properItem = nsConstraint.firstItem
            } else if nsConstraint.secondItem === self {
                properItem = nsConstraint.secondItem
            }

            guard let properItem = properItem else { return nil }
            let viewIsFirstItem = properItem === nsConstraint.firstItem
            let attribute = viewIsFirstItem
                ? nsConstraint.firstAttribute
                : nsConstraint.secondAttribute

            guard let kind = ConstraintKind(attribute: attribute) else { return nil }
            return ParsedConstraint(kind: kind, constraint: nsConstraint)
        }
        return Set(array)
    }
}

extension UIView {

    var constraintUpdater: ConstraintUpdater { ConstraintUpdater(view: self) }

    struct ConstraintUpdater {
        private let view: UIView

        init(view: UIView) {
            self.view = view
        }

        func updateEdgeInsets(insets: UIEdgeInsets) {
            assert(hasConstraints(kinds: [.top, .bottom, .left, .right]))

            view.parsedConstraints.forEach { item in
                switch item.kind {
                case .top:
                    item.constraint.constant = insets.top
                case .bottom:
                    item.constraint.constant = -insets.bottom
                case .left:
                    item.constraint.constant = insets.left
                case .right:
                    item.constraint.constant = -insets.right
                default:
                    break
                }
            }
        }

        func updateWidth(to value: CGFloat) {
            assert(hasConstraints(kinds: [.width]))
            view.parsedConstraints.forEach { item in
                switch item.kind {
                case .width:
                    item.constraint.constant = value
                default:
                    break
                }
            }
        }

        /// Проверяем что есть констрейнты которые хотим обновить
        private func hasConstraints(kinds contraintsToFind: [UIView.ConstraintKind]) -> Bool {
            let parsedConstraintsKinds = view.parsedConstraints.map(\.kind)
            return contraintsToFind.allSatisfy { kind in
                parsedConstraintsKinds.contains(kind)
            }
        }
    }
}

// MARK: - Constraints

extension UIView {

    struct ParsedConstraint: Hashable, Equatable {
        let kind: ConstraintKind
        let constraint: NSLayoutConstraint
    }

    enum ConstraintKind: CaseIterable {
        case left, right, top, bottom, centerX, centerY, height, width

        init?(attribute: NSLayoutConstraint.Attribute) {
            guard let item = Self.allCases.first(where: { $0.attribute == attribute })
            else { return nil }
            self = item
        }

        var attribute: NSLayoutConstraint.Attribute {
            switch self {
            case .left: return .left
            case .right: return .right
            case .top: return .top
            case .bottom: return .bottom
            case .centerX: return .centerX
            case .centerY: return .centerY
            case .height: return .height
            case .width: return .width
            }
        }
    }
}
