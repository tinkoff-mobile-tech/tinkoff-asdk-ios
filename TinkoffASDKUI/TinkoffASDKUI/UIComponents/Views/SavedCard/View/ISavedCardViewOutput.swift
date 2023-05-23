//
//  ISavedCardViewOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

protocol ISavedCardViewOutput: ISavedCardViewPresenterInput, AnyObject {
    var view: ISavedCardViewInput? { get set }

    func savedCardViewDidBeginCVCFieldEditing()
    func savedCardView(didChangeCVC cvcInputText: String)
    func savedCardViewIsSelected()
}
