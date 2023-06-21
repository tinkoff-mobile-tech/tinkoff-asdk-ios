//
//  IAddNewCardView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import Foundation

protocol IAddNewCardView: AnyObject {
    func reloadCollection(sections: [AddNewCardSection])
    var isLoading: Bool { get }
    func showLoadingState()
    func hideLoadingState()
    func closeScreen()
    func setAddButton(enabled: Bool, animated: Bool)
    func activateCardField()
    func showOkNativeAlert(data: OkAlertData)
    func showCardScanner(completion: @escaping CardScannerCompletion)
}

extension IAddNewCardView {

    func setAddButton(enabled: Bool) {
        setAddButton(enabled: enabled, animated: true)
    }
}
