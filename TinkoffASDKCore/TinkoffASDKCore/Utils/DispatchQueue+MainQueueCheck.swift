//
//
//  DispatchQueue+MainQueueCheck.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Foundation

private let mainQueueSpecificKey = DispatchSpecificKey<UnsafeMutableRawPointer>()
private let mainQueueSpecificValue = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 0)

extension DispatchQueue {
    
    static let mainQueueSetSpecific: Void = {
        DispatchQueue.main.setSpecific(key: mainQueueSpecificKey, value: mainQueueSpecificValue)
        return ()
    }()
    
    public static var isMainQueue: Bool {
        DispatchQueue.mainQueueSetSpecific
        return getSpecific(key: mainQueueSpecificKey) == mainQueueSpecificValue
    }
    
    public static func safePerformOnMainQueueAsync(_ closure: () -> Void) {
        if isMainQueue {
            closure()
        } else {
            main.sync(execute: closure)
        }
    }
    
    public static func safePerformOnMainQueueSync(_ closure: () -> Void) {
        if isMainQueue || Thread.isMainThread {
            closure()
        } else {
            main.sync(execute: closure)
        }
    }
}
