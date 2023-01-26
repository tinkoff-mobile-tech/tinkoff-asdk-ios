//
//  ISavedCardViewOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

protocol ISavedCardViewOutput: AnyObject {
    var view: ISavedCardViewInput? { get set }

    func cvcFieldDidBeginEditing()
    func cvcField(didFillWith text: String)
    func didSelectView()
}
