//
//  ITinkoffPayAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.03.2023.
//

import Foundation

protocol ITinkoffPayAssembly {
    func tinkoffPayAppChecker() -> ITinkoffPayAppChecker
    func tinkoffPayController() -> ITinkoffPayController
}
