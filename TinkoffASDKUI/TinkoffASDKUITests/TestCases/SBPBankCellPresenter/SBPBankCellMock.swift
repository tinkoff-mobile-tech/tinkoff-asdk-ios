//
//  SBPBankCellMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 25.04.2023.
//

import Foundation

@testable import TinkoffASDKUI

final class SBPBankCellMock: NSObject, ISBPBankCell {
    var presenter: ISBPBankCellPresenter?

    // MARK: - showSkeletonViews

    var showSkeletonViewsCallsCount = 0

    func showSkeletonViews() {
        showSkeletonViewsCallsCount += 1
    }

    // MARK: - set

    var setCallsCount = 0
    var setReceivedArguments: UITableViewCell.SelectionStyle?
    var setReceivedInvocations: [UITableViewCell.SelectionStyle] = []

    func set(selectionStyle: UITableViewCell.SelectionStyle) {
        setCallsCount += 1
        let arguments = (selectionStyle)
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }

    // MARK: - setNameLabel

    var setNameLabelCallsCount = 0
    var setNameLabelReceivedArguments: String?
    var setNameLabelReceivedInvocations: [String?] = []

    func setNameLabel(text: String?) {
        setNameLabelCallsCount += 1
        let arguments = (text)
        setNameLabelReceivedArguments = arguments
        setNameLabelReceivedInvocations.append(arguments)
    }

    // MARK: - setLogo

    typealias SetLogoArguments = (image: UIImage?, animated: Bool)

    var setLogoCallsCount = 0
    var setLogoReceivedArguments: SetLogoArguments?
    var setLogoReceivedInvocations: [SetLogoArguments] = []

    func setLogo(image: UIImage?, animated: Bool) {
        setLogoCallsCount += 1
        let arguments = (image, animated)
        setLogoReceivedArguments = arguments
        setLogoReceivedInvocations.append(arguments)
    }
}
