//
//  ISwitchViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

protocol ISwitchViewPresenterAssembly {
    func build(title: String, isOn: Bool, actionBlock: SwitchViewPresenterActionBlock?) -> ISwitchViewOutput
}

extension ISwitchViewPresenterAssembly {
    func build(title: String) -> ISwitchViewOutput {
        build(title: title, isOn: false, actionBlock: nil)
    }

    func build(title: String, isOn: Bool) -> ISwitchViewOutput {
        build(title: title, isOn: isOn, actionBlock: nil)
    }

    func build(title: String, actionBlock: SwitchViewPresenterActionBlock?) -> ISwitchViewOutput {
        build(title: title, isOn: false, actionBlock: actionBlock)
    }
}
