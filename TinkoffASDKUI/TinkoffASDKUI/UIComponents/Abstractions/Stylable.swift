//
//
//  StyleAvailable.swift
//
//  Copyright (c) 2022 Tinkoff Bank
//
//

import UIKit

/// Объект, который может хранить свой стиль
protocol StyleAvailable: AnyObject {
    associatedtype Style

    var style: Style? { get set }
}

/// Объект, к которому может быть применен стиль без его сохранения
protocol StyleApplicable: AnyObject {
    associatedtype Style

    func apply(style: Style)
}

protocol Stylable: StyleAvailable, StyleApplicable {}
