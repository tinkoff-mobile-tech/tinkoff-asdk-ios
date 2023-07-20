//
//  BasePage.swift
//  UITests
//
//  Created by a.peresypkin on 25.05.2020.
//  Copyright © 2020 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import Foundation
import XCTest

open class BasePage {

    lazy var app: XCUIApplication = ApplicationHolder.shared.application
}
