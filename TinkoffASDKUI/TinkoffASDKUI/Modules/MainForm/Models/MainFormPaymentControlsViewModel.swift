//
//  MainFormPaymentControlsViewModel.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.01.2023.
//

import Foundation

struct MainFormPaymentControlsViewModel {
    enum ButtonType {
        case primary(title: String)
    }

    let buttonType: ButtonType
}
