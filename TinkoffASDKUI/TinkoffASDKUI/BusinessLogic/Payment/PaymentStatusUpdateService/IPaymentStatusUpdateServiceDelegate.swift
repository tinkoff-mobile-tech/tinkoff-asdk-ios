//
//  IPaymentStatusUpdateServiceDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.02.2023.
//

protocol IPaymentStatusUpdateServiceDelegate: AnyObject {
    func paymentFinalStatusRecieved(data: FullPaymentData)
    func paymentCancelStatusRecieved(data: FullPaymentData)
    func paymentFailureStatusRecieved(data: FullPaymentData, error: Error)
}
