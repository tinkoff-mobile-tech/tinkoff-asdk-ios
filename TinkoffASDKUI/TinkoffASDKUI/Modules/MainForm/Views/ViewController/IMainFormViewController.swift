//
//  IMainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation

protocol IMainFormViewController: AnyObject {
    func setButtonPrimaryAppearance()
    func setButtonTinkoffPayAppearance()
    func setButtonSBPAppearance()
    func setButtonEnabled(_ enabled: Bool)
    func reloadData()
}
