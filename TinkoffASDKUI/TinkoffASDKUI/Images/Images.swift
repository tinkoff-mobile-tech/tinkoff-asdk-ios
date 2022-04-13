//
//  Images.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2022 Tinkoff Bank
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

import UIKit

struct Images {
    struct TinkoffPay {
        static var logoBlack: UIImage? {
            UIImage(named: "tinkoff_pay_logo_black", in: .uiResources, compatibleWith: nil)
        }
        
        static var logoWhite: UIImage? {
            UIImage(named: "tinkoff_pay_logo_white", in: .uiResources, compatibleWith: nil)
        }
    }
}
