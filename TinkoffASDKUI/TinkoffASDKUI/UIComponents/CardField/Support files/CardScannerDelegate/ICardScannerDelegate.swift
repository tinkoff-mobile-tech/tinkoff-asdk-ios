//
//  ICardScannerDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.04.2023.
//

import UIKit

/// Замыкание, в которое необходимо передать карточные данные по завершении сканирования
public typealias CardScannerCompletion = (_ cardNumber: String?, _ expiration: String?, _ cvc: String?) -> Void

/// Делегат, предоставляющий возможность отобразить карточный сканер поверх заданного экрана
public protocol ICardScannerDelegate: AnyObject {
    /// Уведомляет о нажатии пользователем на кнопку сканера при вводе карточных данных
    ///
    /// Объект, реализующий данный протокол, должен отобразить экран со сканером.
    /// После завершения сканирования необходимо передать полученные карточные данные в `completion`
    /// - Parameters:
    ///   - viewController:`UIViewController`, поверх которого необходимо отобразить экран со сканером
    ///   - completion: Замыкание, в которое необходимо передать карточные данные по завершении сканирования
    func cardScanButtonDidPressed(on viewController: UIViewController, completion: @escaping CardScannerCompletion)
}
