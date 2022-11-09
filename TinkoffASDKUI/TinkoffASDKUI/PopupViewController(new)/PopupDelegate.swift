//
//  PopupDelegate.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.10.2022.
//

import Foundation

protocol PopupDelegate: AnyObject {

    /// When unfolded value is equal to 1 for folded -1
    /// When did't changed the position value is 0
    ///
    /// In order to get a value between 1 and 0 the formula is (1 + value) / 2
    func updatedFractionComplete(value: Double)
    /// Called only when used a fast swiping gesture
    func willUnfold()
    func didUnfold()
    func willFold()
    func didFold()
}
