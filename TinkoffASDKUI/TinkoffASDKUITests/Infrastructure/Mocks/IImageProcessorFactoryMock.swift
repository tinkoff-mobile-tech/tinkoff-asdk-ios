//
//  IImageProcessorFactoryMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class ImageProcessorFactoryMock: IImageProcessorFactory {

    // MARK: - makeImageProcesssors

    typealias MakeImageProcesssorsArguments = CellImageLoaderType

    var makeImageProcesssorsCallsCount = 0
    var makeImageProcesssorsReceivedArguments: MakeImageProcesssorsArguments?
    var makeImageProcesssorsReceivedInvocations: [MakeImageProcesssorsArguments?] = []
    var makeImageProcesssorsReturnValue: [ImageProcessor] = []

    func makeImageProcesssors(for type: CellImageLoaderType) -> [ImageProcessor] {
        makeImageProcesssorsCallsCount += 1
        let arguments = type
        makeImageProcesssorsReceivedArguments = arguments
        makeImageProcesssorsReceivedInvocations.append(arguments)
        return makeImageProcesssorsReturnValue
    }
}

// MARK: - Resets

extension ImageProcessorFactoryMock {
    func fullReset() {
        makeImageProcesssorsCallsCount = 0
        makeImageProcesssorsReceivedArguments = nil
        makeImageProcesssorsReceivedInvocations = []
    }
}
