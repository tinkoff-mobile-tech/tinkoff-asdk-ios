//
//  CommonSheetIO.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation

protocol ICommonSheetView: AnyObject {
    func update(state: CommonSheetState, animatePullableContainerUpdates: Bool)
    func close()
}

extension ICommonSheetView {
    func update(state: CommonSheetState) {
        update(state: state, animatePullableContainerUpdates: true)
    }
}

protocol ICommonSheetPresenter {
    func viewDidLoad()
    func primaryButtonTapped()
    func secondaryButtonTapped()
    func canDismissViewByUserInteraction() -> Bool
    func viewWasClosed()
}
