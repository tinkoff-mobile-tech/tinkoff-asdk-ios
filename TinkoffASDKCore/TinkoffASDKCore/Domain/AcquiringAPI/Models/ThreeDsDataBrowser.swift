//
//  ThreeDsDataBrowser.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 01.08.2023.
//

import Foundation

/// Для проведения 3дс транзакции Browser Flow
public struct ThreeDsDataBrowser: Encodable {
    /// Indicates whether the 3DS Method successfully completed.
    ///
    /// Y - Successfully completed.
    /// N - Did not run or did not successfully complete.
    /// U - Unavailable 3DS Method URL was not present in the PRes message data.
    public let threeDSCompInd: String

    /// Boolean in string format that represents the ability of the cardholder browser to execute Java.
    ///
    /// Values: true, false
    public let javaEnabled: String?

    /// Value representing the bit depth of the colour palette for displaying images, in bits per pixel.
    ///
    /// Values accepted: 1–99
    public let colorDepth: String?

    /// Value representing the browser language
    public let language: String

    /// Time-zone offset in minutes
    public let timezone: String

    /// Total height of the Cardholder’s screen
    public let screenHeight: String

    /// Total width of the Cardholder’s screen
    public let screenWidth: String

    /// Url that should be called once 3DS verification was succesfull
    public let cresCallbackUrl: String

    public init(
        threeDSCompInd: String,
        javaEnabled: String?,
        colorDepth: String?,
        language: String,
        timezone: String,
        screenHeight: String,
        screenWidth: String,
        cresCallbackUrl: String
    ) {
        self.threeDSCompInd = threeDSCompInd
        self.javaEnabled = javaEnabled
        self.colorDepth = colorDepth
        self.language = language
        self.timezone = timezone
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.cresCallbackUrl = cresCallbackUrl
    }

    public enum CodingKeys: String, CodingKey {
        case threeDSCompInd
        case javaEnabled
        case colorDepth
        case language
        case timezone
        case screenHeight = "screen_height"
        case screenWidth = "screen_width"
        case cresCallbackUrl
    }
}
