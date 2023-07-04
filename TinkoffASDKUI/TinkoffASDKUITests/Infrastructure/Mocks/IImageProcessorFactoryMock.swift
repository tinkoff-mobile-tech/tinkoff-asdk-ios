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

    var makeImageProcesssorsCallsCount = 0
    var makeImageProcesssorsReceivedArguments: CellImageLoaderType?
    var makeImageProcesssorsReceivedInvocations: [CellImageLoaderType] = []
    var makeImageProcesssorsReturnValue: [ImageProcessor] = []

    func makeImageProcesssors(for type: CellImageLoaderType) -> [ImageProcessor] {
        makeImageProcesssorsCallsCount += 1
        let arguments = type
        makeImageProcesssorsReceivedArguments = arguments
        makeImageProcesssorsReceivedInvocations.append(arguments)
        return makeImageProcesssorsReturnValue
    }
}
