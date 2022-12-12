//
//  TextFieldEvent.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

@frozen public enum TextFieldEvent {
    case didBeginEditing
    case textDidChange
    case didEndEditing
}
