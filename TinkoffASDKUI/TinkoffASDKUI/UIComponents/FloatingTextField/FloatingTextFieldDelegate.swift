//
//  FloatingTextFieldDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 31.01.2023.
//

import UIKit

protocol FloatingTextFieldDelegate: AnyObject {
    func textField(_ textField: UITextField, didChangeTextTo newText: String)

    func textFieldShouldReturn(_ textField: UITextField) -> Bool

    func textFieldDidBeginEditing(_ textField: UITextField)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldDidEndEditing(_ textField: UITextField)
}

extension FloatingTextFieldDelegate {
    func textField(_ textField: UITextField, didChangeTextTo newText: String) {}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { true }

    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { true }
    func textFieldDidEndEditing(_ textField: UITextField) {}
}
