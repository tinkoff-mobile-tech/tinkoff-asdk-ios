//
//  IAddNewCardPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import Foundation

protocol IAddNewCardPresenter: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    func cardFieldViewAddCardTapped()
    func viewWasClosed()
    func cardFieldViewPresenter() -> ICardFieldViewOutput
}
