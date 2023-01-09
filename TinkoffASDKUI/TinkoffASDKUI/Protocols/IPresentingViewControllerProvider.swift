//
//  IPresentingViewControllerProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import UIKit

public protocol IPresentingViewControllerProvider: AnyObject {
    func viewControllerForPresentation() -> UIViewController?
}
