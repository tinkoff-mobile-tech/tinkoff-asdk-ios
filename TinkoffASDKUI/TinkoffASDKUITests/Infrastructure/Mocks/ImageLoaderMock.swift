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
    var loadImageReceivedInvocations: [LoadImageArguments?] = []
    var loadImagePreCacheClosureClosureInput: UIImage?
    var loadImageCompletionClosureInput: Result<UIImage, Swift.Error>?
    var loadImageReturnValue: UUID?

    @discardableResult
    func loadImage(url: URL, preCacheClosure: @escaping (UIImage) -> UIImage, completion: @escaping (Result<UIImage, Swift.Error>) -> Void) -> UUID? {
        loadImageCallsCount += 1
        let arguments = (url, preCacheClosure, completion)
        loadImageReceivedArguments = arguments
        loadImageReceivedInvocations.append(arguments)
        if let loadImagePreCacheClosureClosureInput = loadImagePreCacheClosureClosureInput {
            _ = preCacheClosure(loadImagePreCacheClosureClosureInput)
        }
        if let loadImageCompletionClosureInput = loadImageCompletionClosureInput {
            completion(loadImageCompletionClosureInput)
        }
        return loadImageReturnValue
    }

    // MARK: - cancelImageLoad

    typealias CancelImageLoadArguments = UUID

    var cancelImageLoadCallsCount = 0
    var cancelImageLoadReceivedArguments: CancelImageLoadArguments?
    var cancelImageLoadReceivedInvocations: [CancelImageLoadArguments?] = []

    func cancelImageLoad(uuid: UUID) {
        cancelImageLoadCallsCount += 1
        let arguments = uuid
        cancelImageLoadReceivedArguments = arguments
        cancelImageLoadReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension ImageLoaderMock {
    func fullReset() {
        loadImageCallsCount = 0
        loadImageReceivedArguments = nil
        loadImageReceivedInvocations = []
        loadImagePreCacheClosureClosureInput = nil
        loadImageCompletionClosureInput = nil

        cancelImageLoadCallsCount = 0
        cancelImageLoadReceivedArguments = nil
        cancelImageLoadReceivedInvocations = []
    }
}
