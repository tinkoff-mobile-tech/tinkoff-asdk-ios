//
//  IAddCardControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

protocol IAddCardControllerAssembly {
    func addCardController(customerKey: String) -> IAddCardController
}
