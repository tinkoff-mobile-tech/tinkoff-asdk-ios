//
//  UIImageView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

extension UIImageView {
    func loadImage(at url: URL, type: CellImageLoaderType = .default) {
        CellImageLoader.loader.set(type: type)
        CellImageLoader.loader.loadRemoteImage(url: url, imageView: self)
    }

    func cancelImageLoad() {
        CellImageLoader.loader.cancelLoadIfNeeded(imageView: self)
    }
}
