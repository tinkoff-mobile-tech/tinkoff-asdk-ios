//
//  IAddCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Объект, с помощью которого можно привязать новую карту с прохождением проверки `3DS`
public protocol IAddCardController: AnyObject {
    /// Объект, предоставляющий UI-компоненты для прохождения 3DS Web Based Flow
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    /// Привязывает новую карту с заданными параметрами к пользователю
    /// - Parameters:
    ///   - options: Опции добавления карты
    ///   - completion: Замыкание с результатом привязки карты, вызывающееся на главном потоке
    func addCard(options: CardOptions, completion: @escaping (AddCardStateResult) -> Void)
}
