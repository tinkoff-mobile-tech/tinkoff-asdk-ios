//
//  ImageLoaderTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 10.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class ImageLoaderTests: XCTestCase {
    // MARK: Properties

    private var sut: ImageLoader!
    private var urlDataLoaderMock: DataLoaderMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        urlDataLoaderMock = DataLoaderMock()
        sut = ImageLoader(urlDataLoader: urlDataLoaderMock)
    }

    override func tearDown() {
        urlDataLoaderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_thatImageLoaderReturnsFailedToLoadImage() {
        // given
        urlDataLoaderMock.loadDataCompletionClosureInput = .success(Data())
        urlDataLoaderMock.loadDataReturnValue = CancellableMock()

        // when
        var result: Result<UIImage, Error>?
        sut.loadImage(url: .fakeVK, preCacheClosure: { _ in UIImage() }, completion: { result = $0 })

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(error as NSError, ImageLoader.Error.failedToLoadImage as NSError)
        } else {
            XCTFail()
        }
    }

    func test_thatImageLoaderReturnsCachedImage() throws {
        // give
        let image = Asset.TinkoffPay.tinkoffPayAvatar.image
        let data = try XCTUnwrap(image.pngData())
        urlDataLoaderMock.loadDataCompletionClosureInput = .success(data)
        urlDataLoaderMock.loadDataReturnValue = CancellableMock()

        // when
        var invokedPreCacheClosure = false
        var result: Result<UIImage, Error>?
        sut.loadImage(
            url: .fakeVK,
            preCacheClosure: { _ in
                invokedPreCacheClosure = true
                return image
            },
            completion: { result = $0 }
        )
        sut.loadImage(url: .fakeVK, preCacheClosure: { _ in UIImage() }, completion: { result = $0 })

        // then
        XCTAssertTrue(invokedPreCacheClosure)
        if case let .success(resultImage) = result {
            XCTAssertEqual(resultImage, image)
        } else {
            XCTFail()
        }
    }

    func test_thatImageLoaderReturnsError_whenRequestDidFail() {
        // give
        let errorStub = ErrorStub()
        urlDataLoaderMock.loadDataCompletionClosureInput = .failure(errorStub)
        urlDataLoaderMock.loadDataReturnValue = CancellableMock()

        // when
        var result: Result<UIImage, Error>?
        sut.loadImage(url: .fakeVK, preCacheClosure: { _ in UIImage() }, completion: { result = $0 })

        // then
        if case let .failure(error) = result {
            XCTAssertEqual(errorStub as NSError, error as NSError)
        } else {
            XCTFail()
        }
    }

    func test_thatImageLoaderDoesNoting_whenRequestIsCancelled() {
        // give
        let errorStub = NSError(domain: "Error", code: NSURLErrorCancelled)
        urlDataLoaderMock.loadDataCompletionClosureInput = .failure(errorStub)
        urlDataLoaderMock.loadDataReturnValue = CancellableMock()

        // when
        var result: Result<UIImage, Error>?
        sut.loadImage(url: .fakeVK, preCacheClosure: { _ in UIImage() }, completion: { result = $0 })

        // then
        if case .failure = result { XCTFail() }
        if case .success = result { XCTFail() }
    }

    func test_thatImageLoaderCancelsDownload() throws {
        // given
        let cancellableMock = CancellableMock()
        urlDataLoaderMock.loadDataReturnValue = cancellableMock

        // when
        let uuid = try XCTUnwrap(sut.loadImage(url: .fakeVK, preCacheClosure: { _ in UIImage() }, completion: { _ in }))
        sut.cancelImageLoad(uuid: uuid)

        // then
        XCTAssertEqual(cancellableMock.cancelCallsCount, 1)
    }
}
