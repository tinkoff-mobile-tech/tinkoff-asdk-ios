//
//  CommonSheetPresenterMock.swift
//  Pods
//
//  Created by Ivan Glushko on 23.05.2023.
//

@testable import TinkoffASDKUI

final class CommonSheetPresenterMock: ICommonSheetPresenter {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - primaryButtonTapped

    var primaryButtonTappedCallsCount = 0

    func primaryButtonTapped() {
        primaryButtonTappedCallsCount += 1
    }

    // MARK: - secondaryButtonTapped

    var secondaryButtonTappedCallsCount = 0

    func secondaryButtonTapped() {
        secondaryButtonTappedCallsCount += 1
    }

    // MARK: - canDismissViewByUserInteraction

    var canDismissViewByUserInteractionCallsCount = 0
    var canDismissViewByUserInteractionReturnValue: Bool!

    func canDismissViewByUserInteraction() -> Bool {
        canDismissViewByUserInteractionCallsCount += 1
        return canDismissViewByUserInteractionReturnValue
    }

    // MARK: - viewWasClosed

    var viewWasClosedCallsCount = 0

    func viewWasClosed() {
        viewWasClosedCallsCount += 1
    }
}
