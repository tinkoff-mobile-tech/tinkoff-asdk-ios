//
//  Global.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.12.2022.
//

import Foundation

func performOnMain(_ closure: @escaping @convention(block) () -> Void) {
    guard !Thread.isMainThread else {
        closure()
        return
    }

    DispatchQueue.main.async(execute: closure)
}
