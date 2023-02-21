//
//  IAddNewCardView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import Foundation

protocol IAddNewCardView: AnyObject {
    func reloadCollection(sections: [AddNewCardSection])
    func showLoadingState()
    func hideLoadingState()
    func closeScreen()
    func disableAddButton()
    func enableAddButton()
    func activateCardField()
    func showOkNativeAlert(data: OkAlertData)
}
