//
//  IQrImageViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

protocol IQrImageViewOutput: AnyObject {
    var view: IQrImageViewInput? { get set }

    func qrDidLoad()
}
