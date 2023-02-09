//
//  IPaymentStatusUpdateService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.02.2023.
//

protocol IPaymentStatusUpdateService: AnyObject {
    var delegate: IPaymentStatusUpdateServiceDelegate? { get set }

    func startUpdateStatusIfNeeded(data: FullPaymentData)
}
