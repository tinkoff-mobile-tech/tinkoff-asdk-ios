//
//  IEmailViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

protocol IEmailViewOutput: AnyObject {
    var view: IEmailViewInput? { get set }

    func textFieldDidBeginEditing()
    func textFieldDidChangeText(to text: String)
    func textFieldDidEndEditing()

    func textFieldDidPressReturn()
}
