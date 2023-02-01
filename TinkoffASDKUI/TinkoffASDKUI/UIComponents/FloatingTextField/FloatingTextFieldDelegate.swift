//
//  FloatingTextFieldDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 31.01.2023.
//

import UIKit

protocol FloatingTextFieldDelegate: AnyObject {
    func textField(_ textField: UITextField, didChangeTextTo newText: String)

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    func textFieldDidEndEditing(_ textField: UITextField)

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    func textFieldShouldClear(_ textField: UITextField) -> Bool
}

extension FloatingTextFieldDelegate {
    func textField(_ textField: UITextField, didChangeTextTo newText: String) {}

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { true }
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { true }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool { true }
    func textFieldDidEndEditing(_ textField: UITextField) {}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { true }
    func textFieldShouldClear(_ textField: UITextField) -> Bool { true }
}
