//
//  IRecurrentPaymentViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

protocol IRecurrentPaymentViewInput: AnyObject {
    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool)
    func hideCommonSheet()

    func hideKeyboard()

    func reloadData()
    func closeView()
}

extension IRecurrentPaymentViewInput {
    func showCommonSheet(state: CommonSheetState) {
        showCommonSheet(state: state, animatePullableContainerUpdates: true)
    }
}
