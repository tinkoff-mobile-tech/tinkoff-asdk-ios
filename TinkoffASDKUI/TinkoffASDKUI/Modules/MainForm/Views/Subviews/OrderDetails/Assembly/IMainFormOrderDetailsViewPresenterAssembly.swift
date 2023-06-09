//
//  IMainFormOrderDetailsViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

protocol IMainFormOrderDetailsViewPresenterAssembly {
    func build(amount: Int64, orderDescription: String?) -> any IMainFormOrderDetailsViewOutput
}
