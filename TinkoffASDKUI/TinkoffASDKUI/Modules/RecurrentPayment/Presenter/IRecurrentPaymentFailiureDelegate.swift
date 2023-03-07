//
//  IRecurrentPaymentFailiureDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 07.03.2023.
//

public typealias PaymentId = String

public protocol IRecurrentPaymentFailiureDelegate: AnyObject {
    func recurrentPaymentNeedRepeatInit(completion: @escaping (Result<PaymentId, Error>) -> Void)
}
