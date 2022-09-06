//
//  TinkoffPayButton.swift
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
//

import UIKit

public final class TinkoffPayButton: UIButton {
    
    public struct DynamicStyle {
        let lightStyle: Style
        let darkStyle: Style
        
        public init(lightStyle: Style,
                    darkStyle: Style) {
            self.lightStyle = lightStyle
            self.darkStyle = darkStyle
        }
    }
    
    public struct Style {
        public enum Color {
            case black
            case white
        }
        
        public static var black: Style {
            .init(color: .black, isBordered: false)
        }
        
        public static var blackBordered: Style {
            .init(color: .black, isBordered: true)
        }
        
        public static var white: Style {
            .init(color: .white, isBordered: false)
        }
        
        public static var whiteBordered: Style {
            .init(color: .white, isBordered: true)
        }
        
        let color: Color
        let isBordered: Bool
        
        var backgroundColor: UIColor {
            switch color {
            case .black: return .asdk.n15
            case .white: return .asdk.n14
            }
        }
        
        var highlightBackgroundColor: UIColor {
            switch color {
            case .black: return .asdk.black
            case .white: return .asdk.n7
            }
        }
        
        var borderColor: UIColor {
            switch color {
            case .black: return .asdk.n14
            case .white: return .asdk.n15
            }
        }
        
        var image: UIImage? {
            switch color {
            case .black: return Asset.TinkoffPay.tinkoffPayLogoBlack.image
            case .white: return Asset.TinkoffPay.tinkoffPayLogoWhite.image
            }
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            guard #available(iOS 15.0, *) else {
                guard isHighlighted != oldValue else { return }
                backgroundColor = isHighlighted ? style.highlightBackgroundColor : style.backgroundColor
                return
            }
        }
    }
    
    private var style: Style {
        didSet {
            updateStyle()
        }
    }
    private var dynamicStyle: DynamicStyle?
    
    public init(style: Style = .black) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    public convenience init(dynamicStyle: DynamicStyle) {
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                self.init(style: dynamicStyle.darkStyle)
            default:
                self.init(style: dynamicStyle.lightStyle)
            }
        } else {
            self.init(style: dynamicStyle.lightStyle)
        }
        self.dynamicStyle = dynamicStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        .init(width: .minimumWidth, height: .minimumHeight)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let dynamicStyle = dynamicStyle else {
            return
        }
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                self.style = dynamicStyle.darkStyle
            default:
                self.style = dynamicStyle.lightStyle
            }
        }
    }
}

private extension TinkoffPayButton {
    func setup() {
        updateStyle()
    }
    
    func updateStyle() {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.image = style.image
            if style.isBordered {
                configuration.background.strokeWidth = .borderWidth
                configuration.background.strokeColor = style.borderColor
            }
            self.configuration = configuration
            self.configurationUpdateHandler = { [style] button in
                switch button.state {
                case .highlighted, .disabled:
                    configuration.background.backgroundColor = style.highlightBackgroundColor
                default:
                    configuration.background.backgroundColor = style.backgroundColor
                }
                button.configuration = configuration
            }
        } else {
            setImage(style.image, for: .normal)
            backgroundColor = style.backgroundColor
            adjustsImageWhenHighlighted = false
            layer.cornerRadius = .cornerRadius
            if style.isBordered {
                layer.borderColor = style.borderColor.cgColor
                layer.borderWidth = .borderWidth
            }
        }
    }
}

private extension CGFloat {
    static let cornerRadius: CGFloat = 4
    static let borderWidth: CGFloat = 1
    static let minimumHeight: CGFloat = 44
    static let minimumWidth: CGFloat = 150
}

