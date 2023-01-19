//
//  MainFormPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation

final class MainFormPresenter {
    // MARK: Dependencies

    weak var view: IMainFormViewController?
    private let router: IMainFormRouter
    private let stub: MainFormStub

    // MARK: Init

    init(router: IMainFormRouter, stub: MainFormStub) {
        self.router = router
        self.stub = stub
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {}
}
