//
//  TinkoffPayControllerDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation
import TinkoffASDKCore

protocol TinkoffPayControllerDelegate: AnyObject {
    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, didReceive payload: GetPaymentStatePayload)
    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, failedWith error: Error)
    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, succededWith payload: GetPaymentStatePayload)
    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, failedToOpenBankAppWith error: Error)
    func tinkoffPayControllerOpenedBankApp(_ tinkoffPayController: ITinkoffPayController)
}
