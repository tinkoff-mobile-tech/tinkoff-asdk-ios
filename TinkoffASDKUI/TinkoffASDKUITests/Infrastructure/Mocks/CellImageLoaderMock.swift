//
//  CellImageLoaderMock.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation
import UIKit

@testable import TinkoffASDKUI

final class CellImageLoaderMock: ICellImageLoader {

    // MARK: - loadImage

    typealias LoadImageArguments = (url: URL, completion: (Result<UIImage, Swift.Error>) -> Void)

    var loadImageCallsCount = 0
    var loadImageReceivedArguments: LoadImageArguments?
    var loadImageReceivedInvocations: [LoadImageArguments?] = []
    var loadImageCompletionClosureInput: Result<UIImage, Swift.Error>?

    func loadImage(url: URL, completion: @escaping (Result<UIImage, Swift.Error>) -> Void) {
        loadImageCallsCount += 1
        let arguments = (url, completion)
        loadImageReceivedArguments = arguments
        loadImageReceivedInvocations.append(arguments)
        if let loadImageCompletionClosureInput = loadImageCompletionClosureInput {
            completion(loadImageCompletionClosureInput)
        }
    }

    // MARK: - loadAndSetRemoteImage

    typealias LoadAndSetRemoteImageArguments = (url: URL, imageView: UIImageView, onFailureImage: UIImage?)

    var loadAndSetRemoteImageCallsCount = 0
    var loadAndSetRemoteImageReceivedArguments: LoadAndSetRemoteImageArguments?
    var loadAndSetRemoteImageReceivedInvocations: [LoadAndSetRemoteImageArguments?] = []
    var loadAndSetRemoteImageReturnValue: UUID?

    @discardableResult
    func loadAndSetRemoteImage(url: URL, imageView: UIImageView, onFailureImage: UIImage?) -> UUID? {
        loadAndSetRemoteImageCallsCount += 1
        let arguments = (url, imageView, onFailureImage)
        loadAndSetRemoteImageReceivedArguments = arguments
        loadAndSetRemoteImageReceivedInvocations.append(arguments)
        return loadAndSetRemoteImageReturnValue
    }

    // MARK: - cancelLoadIfNeeded

    typealias CancelLoadIfNeededArguments = UIImageView

    var cancelLoadIfNeededCallsCount = 0
    var cancelLoadIfNeededReceivedArguments: CancelLoadIfNeededArguments?
    var cancelLoadIfNeededReceivedInvocations: [CancelLoadIfNeededArguments?] = []

    func cancelLoadIfNeeded(imageView: UIImageView) {
        cancelLoadIfNeededCallsCount += 1
        let arguments = imageView
        cancelLoadIfNeededReceivedArguments = arguments
        cancelLoadIfNeededReceivedInvocations.append(arguments)
    }

    // MARK: - loadRemoteImageJustForCache

    typealias LoadRemoteImageJustForCacheArguments = URL

    var loadRemoteImageJustForCacheCallsCount = 0
    var loadRemoteImageJustForCacheReceivedArguments: LoadRemoteImageJustForCacheArguments?
    var loadRemoteImageJustForCacheReceivedInvocations: [LoadRemoteImageJustForCacheArguments?] = []
    var loadRemoteImageJustForCacheReturnValue: UUID?

    @discardableResult
    func loadRemoteImageJustForCache(url: URL) -> UUID? {
        loadRemoteImageJustForCacheCallsCount += 1
        let arguments = url
        loadRemoteImageJustForCacheReceivedArguments = arguments
        loadRemoteImageJustForCacheReceivedInvocations.append(arguments)
        return loadRemoteImageJustForCacheReturnValue
    }

    // MARK: - cancelLoad

    typealias CancelLoadArguments = UUID

    var cancelLoadCallsCount = 0
    var cancelLoadReceivedArguments: CancelLoadArguments?
    var cancelLoadReceivedInvocations: [CancelLoadArguments?] = []

    func cancelLoad(uuid: UUID) {
        cancelLoadCallsCount += 1
        let arguments = uuid
        cancelLoadReceivedArguments = arguments
        cancelLoadReceivedInvocations.append(arguments)
    }

    // MARK: - set

    typealias SetArguments = CellImageLoaderType

    var setCallsCount = 0
    var setReceivedArguments: SetArguments?
    var setReceivedInvocations: [SetArguments?] = []

    func set(type: CellImageLoaderType) {
        setCallsCount += 1
        let arguments = type
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CellImageLoaderMock {
    func fullReset() {
        loadImageCallsCount = 0
        loadImageReceivedArguments = nil
        loadImageReceivedInvocations = []
        loadImageCompletionClosureInput = nil

        loadAndSetRemoteImageCallsCount = 0
        loadAndSetRemoteImageReceivedArguments = nil
        loadAndSetRemoteImageReceivedInvocations = []

        cancelLoadIfNeededCallsCount = 0
        cancelLoadIfNeededReceivedArguments = nil
        cancelLoadIfNeededReceivedInvocations = []

        loadRemoteImageJustForCacheCallsCount = 0
        loadRemoteImageJustForCacheReceivedArguments = nil
        loadRemoteImageJustForCacheReceivedInvocations = []

        cancelLoadCallsCount = 0
        cancelLoadReceivedArguments = nil
        cancelLoadReceivedInvocations = []

        setCallsCount = 0
        setReceivedArguments = nil
        setReceivedInvocations = []
    }
}
