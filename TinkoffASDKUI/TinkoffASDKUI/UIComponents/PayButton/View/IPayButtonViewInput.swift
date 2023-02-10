//
//  IPayButtonViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

protocol IPayButtonViewInput: AnyObject {
    func set(configuration: Button.Configuration)
    func set(enabled: Bool)
    func startLoading()
    func stopLoading()
}
