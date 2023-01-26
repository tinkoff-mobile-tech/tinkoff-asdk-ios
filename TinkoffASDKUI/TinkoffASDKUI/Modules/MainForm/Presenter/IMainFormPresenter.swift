//
//  IMainFormPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation

protocol IMainFormPresenter {
    func viewDidLoad()
    func viewWasClosed()
    func viewDidTapPayButton()
    func numberOfRows() -> Int
    func viewPresenter(at index: Int) -> MainFormViewPresenterType
}
