//
//  ISwitchViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.01.2023.
//

protocol ISwitchViewInput: AnyObject {
    func setNameLabel(text: String?)
    func setSwitchState(isOn: Bool)
}
