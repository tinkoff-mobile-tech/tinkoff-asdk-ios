//
//  ISBPBankAppOpener.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

typealias SBPBankAppCheckerOpenBankAppCompletion = (Bool) -> Void

protocol ISBPBankAppOpener {
    func openBankApp(url: URL, _ bank: SBPBank, completion: @escaping SBPBankAppCheckerOpenBankAppCompletion)
}
