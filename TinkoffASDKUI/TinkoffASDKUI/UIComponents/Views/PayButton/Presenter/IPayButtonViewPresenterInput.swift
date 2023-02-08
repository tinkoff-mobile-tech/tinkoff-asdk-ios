//
//  IPayButtonViewPresenterInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

protocol IPayButtonViewPresenterInput {
    var isLoading: Bool { get }
    var isEnabled: Bool { get }

    func startLoading()
    func stopLoading()
    func set(enabled: Bool)
}
