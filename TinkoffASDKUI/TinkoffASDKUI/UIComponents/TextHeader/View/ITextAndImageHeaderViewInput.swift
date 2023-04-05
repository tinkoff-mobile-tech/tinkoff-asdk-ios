//
//  ITextAndImageHeaderViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation
import UIKit

protocol ITextAndImageHeaderViewInput: AnyObject {
    func set(title: String?)
    func set(image: UIImage?)
}
