//
//  Extension+UIView.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
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

import UIKit

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }

    /// Находит UIView которая реализует `<T>` в которой расположена текущая UIView
    /// если UIView реализует протокол то позвращаем instance на протокол
    /// - Parameter view: от какого элемента начинать поиск
    /// - Returns: T
    static func searchTableViewCell<T>(by view: UIView?) -> T? {
        var viewResult = view
        if viewResult is T {
            return viewResult as? T
        } else {
            while viewResult?.superview != nil {
                viewResult = viewResult?.superview
                if viewResult is T {
                    return viewResult as? T
                }
            }
        }

        return nil
    }
}
