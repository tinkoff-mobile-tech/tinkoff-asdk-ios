//
//  ISBPPaymentSheetPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 04.02.2023.
//

protocol ISBPPaymentSheetPresenterOutput: AnyObject {
    func sbpPaymentActivity(completedWith result: PaymentResult)
}
