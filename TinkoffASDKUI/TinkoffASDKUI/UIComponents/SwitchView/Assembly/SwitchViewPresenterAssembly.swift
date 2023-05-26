//
//  SwitchViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

final class SwitchViewPresenterAssembly: ISwitchViewPresenterAssembly {
    // MARK: ISwitchViewPresenterAssembly

    func build(title: String, isOn: Bool, actionBlock: SwitchViewPresenterActionBlock?) -> ISwitchViewOutput {
        SwitchViewPresenter(title: title, isOn: isOn, actionBlock: actionBlock)
    }
}
