//
//  ISBPQrViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

protocol ISBPQrViewInput: AnyObject {
    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool)
    func hideCommonSheet()
    func reloadData()
    func closeView()
}

extension ISBPQrViewInput {
    func showCommonSheet(state: CommonSheetState) {
        showCommonSheet(state: state, animatePullableContainerUpdates: true)
    }
}
