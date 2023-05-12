//
//  IMainFormOrderDetailsViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

protocol IMainFormOrderDetailsViewInput: AnyObject {
    func set(amountDescription: String)
    func set(amount: String)
    func set(orderDescription: String?)
}
