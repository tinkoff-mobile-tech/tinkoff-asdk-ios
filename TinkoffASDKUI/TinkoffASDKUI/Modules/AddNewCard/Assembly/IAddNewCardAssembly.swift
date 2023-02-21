//
//  IAddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.02.2023.
//

import Foundation

protocol IAddNewCardAssembly {
    func addNewCard(
        customerKey: String,
        output: IAddNewCardPresenterOutput?
    ) -> AddNewCardViewController

    func addNewCard(
        customerKey: String,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> AddNewCardViewController
}
