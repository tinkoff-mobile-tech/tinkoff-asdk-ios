//
//  CellImageLoaderTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class CellImageLoaderTests: XCTestCase {
    // MARK: Properties

    private var imageLoaderMock: ImageLoaderMock!
    private var imageProcessorFactoryMock: ImageProcessorFactoryMock!

    // MARK: Set Up

    func test_thatCellImageLoaderChangseType_whenTypeIsDefault() {
        // given
        let sut = prepareSut(type: .size(.zero))

        // when
        sut.set(type: .default)

        // then
        XCTAssertEqual(imageProcessorFactoryMock.makeImageProcesssorsCallsCount, 1)
    }

    func test_thatCellImageLoaderChangesType_whenTypeIsSize() {
        // given
        let sut = prepareSut(type: .default)

        // when
        sut.set(type: .size(.zero))

        // then
        XCTAssertEqual(imageProcessorFactoryMock.makeImageProcesssorsCallsCount, 1)
    }

    func test_thatCellImageLoaderChangesType_whenTypeIsRoundAndSize() {
        // given
        let sut = prepareSut(type: .default)

        // when
        sut.set(type: .roundAndSize(.zero))

        // then
        XCTAssertEqual(imageProcessorFactoryMock.makeImageProcesssorsCallsCount, 1)
    }

    func test_thatCellImageLoaderChangesType_whenTypeIsRound() {
        // given
        let sut = prepareSut(type: .default)

        // when
        sut.set(type: .round)

        // then
        XCTAssertEqual(imageProcessorFactoryMock.makeImageProcesssorsCallsCount, 1)
    }

    func test_thatCellImageLoaderCancelsImageLoadRequest() {
        // given
        let uuid = UUID()
        let sut = prepareSut(type: .default)

        // when
        sut.cancelLoad(uuid: uuid)

        // then
        XCTAssertEqual(imageLoaderMock.cancelImageLoadCallsCount, 1)
    }

    func test_thatCellImageLoaderCancelsImageLoadRequest_whenLoadAndSetRemoteImage() {
        // given
        let imageView = UIImageView()
        let sut = prepareSut(type: .default)
        imageLoaderMock.loadImageReturnValue = UUID()

        // when
        sut.loadAndSetRemoteImage(url: .empty, imageView: imageView)
        sut.cancelLoadIfNeeded(imageView: imageView)

        // then
        XCTAssertEqual(imageLoaderMock.cancelImageLoadCallsCount, 1)
    }

    func test_thatCellImageLoaderLoadsRemoteImageJustForCache() {
        // given
        let uuid = UUID()
        let sut = prepareSut(type: .default)
        let processorMock = ImageProcessorMock()
        imageProcessorFactoryMock.makeImageProcesssorsReturnValue = [processorMock]

        imageLoaderMock.loadImagePreCacheClosureClosureInput = UIImage()
        imageLoaderMock.loadImageCompletionClosureInput = .success(UIImage())
        imageLoaderMock.loadImageReturnValue = uuid

        processorMock.processImageReturnValue = UIImage()

        // when
        sut.set(type: .round)
        let result = sut.loadRemoteImageJustForCache(url: .empty)

        // then
        XCTAssertEqual(result, uuid)
        XCTAssertEqual(processorMock.processImageCallsCount, 1)
    }

    func test_thatCellImageLoaderLoadsImage() {
        // given
        let sut = prepareSut(type: .default)
        let processorMock = ImageProcessorMock()
        imageProcessorFactoryMock.makeImageProcesssorsReturnValue = [processorMock]

        imageLoaderMock.loadImagePreCacheClosureClosureInput = UIImage()
        imageLoaderMock.loadImageCompletionClosureInput = .success(UIImage())

        processorMock.processImageReturnValue = UIImage()

        // when
        var isTriggerCompletion = false
        sut.set(type: .round)
        sut.loadImage(url: .empty, completion: { _ in isTriggerCompletion = true })

        // then
        XCTAssertEqual(processorMock.processImageCallsCount, 1)
        XCTAssertTrue(isTriggerCompletion)
    }

    func test_thatCellImageLoaderLoadsImage_whenLoadAndSetRemoteImageSuccess() {
        // given
        let mockImage = UIImage()
        let imageView = UIImageView()
        let sut = prepareSut(type: .default)
        let processorMock = ImageProcessorMock()
        imageProcessorFactoryMock.makeImageProcesssorsReturnValue = [processorMock]

        imageLoaderMock.loadImagePreCacheClosureClosureInput = mockImage
        imageLoaderMock.loadImageCompletionClosureInput = .success(mockImage)

        processorMock.processImageReturnValue = mockImage

        // when
        sut.set(type: .round)
        sut.loadAndSetRemoteImage(url: .empty, imageView: imageView)

        // then
        XCTAssertEqual(processorMock.processImageCallsCount, 1)
        XCTAssertEqual(imageView.image, mockImage)
    }

    func test_thatCellImageLoaderLoadsImage_whenLoadAndSetRemoteImageFailed() {
        // given
        let mockImage = UIImage()
        let imageView = UIImageView()
        let sut = prepareSut(type: .default)
        let processorMock = ImageProcessorMock()
        imageProcessorFactoryMock.makeImageProcesssorsReturnValue = [processorMock]

        imageLoaderMock.loadImagePreCacheClosureClosureInput = mockImage
        imageLoaderMock.loadImageCompletionClosureInput = .failure(ErrorStub())

        processorMock.processImageReturnValue = mockImage

        // when
        sut.set(type: .round)
        sut.loadAndSetRemoteImage(url: .empty, imageView: imageView, onFailureImage: mockImage)

        // then
        XCTAssertEqual(processorMock.processImageCallsCount, 1)
        XCTAssertEqual(imageView.image, mockImage)
    }

    // MARK: Private

    private func prepareSut(type: CellImageLoaderType) -> CellImageLoader {
        imageProcessorFactoryMock = ImageProcessorFactoryMock()
        imageLoaderMock = ImageLoaderMock()
        return CellImageLoader(
            imageLoader: imageLoaderMock,
            type: type,
            imageProcessorFactory: imageProcessorFactoryMock
        )
    }
}
