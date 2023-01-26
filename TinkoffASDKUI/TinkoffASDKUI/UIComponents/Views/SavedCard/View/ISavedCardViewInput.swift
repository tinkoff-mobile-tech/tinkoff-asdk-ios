//
//  ISavedCardViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

protocol ISavedCardViewInput: AnyObject {
    func update(with viewModel: SavedCardViewModel)
    func deactivateCVCField()
}
