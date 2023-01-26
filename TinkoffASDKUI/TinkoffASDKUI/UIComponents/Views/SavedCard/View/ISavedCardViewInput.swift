//
//  ISavedCardViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

protocol ISavedCardViewInput: AnyObject {
    func update(with viewModel: SavedCardViewModel)
    func showCVCField()
    func hideCVCField()
    func setCVCText(_ text: String)
    func setCVCFieldValid()
    func setCVCFieldInvalid()
    func deactivateCVCField()
}
