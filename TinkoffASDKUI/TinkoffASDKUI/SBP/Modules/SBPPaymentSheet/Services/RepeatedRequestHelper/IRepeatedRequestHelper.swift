//
//  IRepeatedRequestHelper.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 18.01.2023.
//

protocol IRepeatedRequestHelper {
    func executeWithWaitingIfNeeded(action: @escaping () -> Void)
}
