//
//  SBPBankCellMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 25.04.2023.
//

import UIKit

@testable import TinkoffASDKUI

final class SBPBankCellMock: NSObject, ISBPBankCell {
    var presenter: ISBPBankCellPresenter?

    // MARK: - showSkeletonViews

    var showSkeletonViewsCallsCount = 0

    func showSkeletonViews() {
        showSkeletonViewsCallsCount += 1
    }

    // MARK: - set

    typealias SetArguments = UITableViewCell.SelectionStyle

    var setCallsCount = 0
    var setReceivedArguments: SetArguments?
    var setReceivedInvocations: [SetArguments?] = []

    func set(selectionStyle: UITableViewCell.SelectionStyle) {
        setCallsCount += 1
        let arguments = selectionStyle
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }

    // MARK: - setNameLabel

    typealias SetNameLabelArguments = String

    var setNameLabelCallsCount = 0
    var setNameLabelReceivedArguments: SetNameLabelArguments?
    var setNameLabelReceivedInvocations: [SetNameLabelArguments?] = []

    func setNameLabel(text: String?) {
        setNameLabelCallsCount += 1
        let arguments = text
        setNameLabelReceivedArguments = arguments
        setNameLabelReceivedInvocations.append(arguments)
    }

    // MARK: - setLogo

    typealias SetLogoArguments = (image: UIImage?, animated: Bool)

    var setLogoCallsCount = 0
    var setLogoReceivedArguments: SetLogoArguments?
    var setLogoReceivedInvocations: [SetLogoArguments?] = []

    func setLogo(image: UIImage?, animated: Bool) {
        setLogoCallsCount += 1
        let arguments = (image, animated)
        setLogoReceivedArguments = arguments
        setLogoReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SBPBankCellMock {
    func fullReset() {
        showSkeletonViewsCallsCount = 0

        setCallsCount = 0
        setReceivedArguments = nil
        setReceivedInvocations = []

        setNameLabelCallsCount = 0
        setNameLabelReceivedArguments = nil
        setNameLabelReceivedInvocations = []

        setLogoCallsCount = 0
        setLogoReceivedArguments = nil
        setLogoReceivedInvocations = []
    }
}
