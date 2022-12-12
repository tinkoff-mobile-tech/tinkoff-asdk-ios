//
//
//  ShadowAvailable.swift
//
//  Copyright (c) 2022 Tinkoff Bank
//
//

import UIKit

protocol ShadowAvailable: AnyObject {

    /// Применяет стиль тени к объекту
    func dropShadow(with style: ShadowStyle)

    /// Удаляет тень
    func removeShadow()
}

/// Структура стиля тени
struct ShadowStyle: Equatable {
    /// Радиус
    var radius: CGFloat
    /// Цвет
    var color: UIColor
    /// Прозрачность
    var opacity: Float
    /// Смещение по оси X
    let offsetX: CGFloat
    /// Смещение по оси Y
    let offsetY: CGFloat

    /// Инициализация
    init(radius: CGFloat, color: UIColor, opacity: Float, offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.opacity = opacity
        self.offsetX = offsetX
        self.offsetY = offsetY
    }

    /// Позволяет конвертировать значение blur radius с фигмы в ios shadow radius
    /// - Parameter figmaBlur: Значение blur'а указанное на макете
    /// - Returns: Shadow radius
    static func getBlurRadius(figmaBlur: CGFloat) -> CGFloat {
        figmaBlur / 2
    }
}

/// ShadowAvailable + UIView
extension ShadowAvailable where Self: UIView {
    /// Применяет стиль тени к объекту
    func dropShadow(with style: ShadowStyle) {
        layer.shadowOffset = CGSize(width: style.offsetX, height: style.offsetY)
        layer.shadowColor = style.color.cgColor
        layer.shadowOpacity = style.opacity
        layer.shadowRadius = style.radius
    }

    /// Удаляет тень
    func removeShadow() {
        layer.shadowOpacity = 0.0
        layer.shadowOffset = .zero
    }
}

// MARK: - Styles

extension ShadowStyle {

    static var medium: Self {
        ShadowStyle(
            radius: Self.getBlurRadius(figmaBlur: 34),
            color: .black,
            opacity: 0.12,
            offsetX: 0,
            offsetY: 6
        )
    }
}
