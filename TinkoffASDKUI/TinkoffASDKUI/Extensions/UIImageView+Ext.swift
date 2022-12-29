//
//  UIImageView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

extension UIImageView {
    func loadImage(at url: URL, type: CellImageLoaderType = .default, onFailureImage: UIImage? = nil) {
        CellImageLoader.loader.set(type: type)
        CellImageLoader.loader.loadRemoteImage(url: url, imageView: self, onFailureImage: onFailureImage)
    }

    func cancelImageLoad() {
        CellImageLoader.loader.cancelLoadIfNeeded(imageView: self)
    }
}
