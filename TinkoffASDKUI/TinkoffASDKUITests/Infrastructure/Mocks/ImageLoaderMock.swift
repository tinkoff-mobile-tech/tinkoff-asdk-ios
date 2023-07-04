//
//  ImageLoaderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class ImageLoaderMock: IImageLoader {

    // MARK: - loadImage

    typealias LoadImageArguments = (url: URL, preCacheClosure: (UIImage) -> UIImage, completion: (Result<UIImage, Swift.Error>) -> Void)

    var loadImageCallsCount = 0
    var loadImageReceivedArguments: LoadImageArguments?
    var loadImageReceivedInvocations: [LoadImageArguments] = []
    var loadImagePreCacheClosureClosureInput: UIImage?
    var loadImageCompletionClosureInput: Result<UIImage, Swift.Error>?
    var loadImageReturnValue: UUID?

    func loadImage(url: URL, preCacheClosure: @escaping (UIImage) -> UIImage, completion: @escaping (Result<UIImage, Swift.Error>) -> Void) -> UUID? {
        loadImageCallsCount += 1
        let arguments = (url, preCacheClosure, completion)
        loadImageReceivedArguments = arguments
        loadImageReceivedInvocations.append(arguments)
        if let loadImagePreCacheClosureClosureInput = loadImagePreCacheClosureClosureInput {
            preCacheClosure(loadImagePreCacheClosureClosureInput)
        }
        if let loadImageCompletionClosureInput = loadImageCompletionClosureInput {
            completion(loadImageCompletionClosureInput)
        }
        return loadImageReturnValue
    }

    // MARK: - cancelImageLoad

    var cancelImageLoadCallsCount = 0
    var cancelImageLoadReceivedArguments: UUID?
    var cancelImageLoadReceivedInvocations: [UUID] = []

    func cancelImageLoad(uuid: UUID) {
        cancelImageLoadCallsCount += 1
        let arguments = uuid
        cancelImageLoadReceivedArguments = arguments
        cancelImageLoadReceivedInvocations.append(arguments)
    }
}
