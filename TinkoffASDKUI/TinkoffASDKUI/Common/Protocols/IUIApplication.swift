//
//  IUIApplication.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import UIKit

protocol IUIApplication {
    func canOpenURL(_ url: URL) -> Bool

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: IUIApplication {}
