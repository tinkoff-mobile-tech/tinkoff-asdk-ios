//
//  ImageProcessorMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class ImageProcessorMock: ImageProcessor {

    // MARK: - processImage

    var processImageCallsCount = 0
    var processImageReceivedArguments: UIImage?
    var processImageReceivedInvocations: [UIImage] = []
    var processImageReturnValue: UIImage!

    func processImage(_ image: UIImage) -> UIImage {
        processImageCallsCount += 1
        let arguments = image
        processImageReceivedArguments = arguments
        processImageReceivedInvocations.append(arguments)
        return processImageReturnValue
    }
}
