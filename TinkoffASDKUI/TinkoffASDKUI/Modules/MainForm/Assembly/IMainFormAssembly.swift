//
//  IMainFormAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

protocol IMainFormAssembly {
    func build(stub: MainFormStub) -> UIViewController
}
