//
//  ICardScannerDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.04.2023.
//

import UIKit

public typealias CardScannerCompletion = (_ cardNumber: String?, _ expiration: String?, _ cvc: String?) -> Void

public protocol ICardScannerDelegate: AnyObject {
    func cardScanButtonDidPressed(on viewController: UIViewController, completion: @escaping CardScannerCompletion)
}
