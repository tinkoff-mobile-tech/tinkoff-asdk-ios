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
    var loadImageReceivedInvocations: [LoadImageArguments] = []
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

    // MARK: - loadRemoteImage

    typealias LoadRemoteImageArguments = (url: URL, imageView: UIImageView, onFailureImage: UIImage?)

    var loadRemoteImageCallsCount = 0
    var loadRemoteImageReceivedArguments: LoadRemoteImageArguments?
    var loadRemoteImageReceivedInvocations: [LoadRemoteImageArguments] = []
    var loadRemoteImageReturnValue: UUID?

    @discardableResult
    func loadRemoteImage(url: URL, imageView: UIImageView, onFailureImage: UIImage?) -> UUID? {
        loadRemoteImageCallsCount += 1
        let arguments = (url, imageView, onFailureImage)
        loadRemoteImageReceivedArguments = arguments
        loadRemoteImageReceivedInvocations.append(arguments)
        return loadRemoteImageReturnValue
    }

    // MARK: - cancelLoadIfNeeded

    var cancelLoadIfNeededCallsCount = 0
    var cancelLoadIfNeededReceivedArguments: UIImageView?
    var cancelLoadIfNeededReceivedInvocations: [UIImageView] = []

    func cancelLoadIfNeeded(imageView: UIImageView) {
        cancelLoadIfNeededCallsCount += 1
        let arguments = imageView
        cancelLoadIfNeededReceivedArguments = arguments
        cancelLoadIfNeededReceivedInvocations.append(arguments)
    }

    // MARK: - loadRemoteImageJustForCache

    var loadRemoteImageJustForCacheCallsCount = 0
    var loadRemoteImageJustForCacheReceivedArguments: URL?
    var loadRemoteImageJustForCacheReceivedInvocations: [URL] = []
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

    var cancelLoadCallsCount = 0
    var cancelLoadReceivedArguments: UUID?
    var cancelLoadReceivedInvocations: [UUID] = []

    func cancelLoad(uuid: UUID) {
        cancelLoadCallsCount += 1
        let arguments = uuid
        cancelLoadReceivedArguments = arguments
        cancelLoadReceivedInvocations.append(arguments)
    }

    // MARK: - set

    var setCallsCount = 0
    var setReceivedArguments: CellImageLoaderType?
    var setReceivedInvocations: [CellImageLoaderType] = []

    func set(type: CellImageLoaderType) {
        setCallsCount += 1
        let arguments = type
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }
}
