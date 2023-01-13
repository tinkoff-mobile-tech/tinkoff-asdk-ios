//
//  ASDKColors.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 11.11.2022.
//

import UIKit

struct ASDKColors {

    static var black: UIColor {
        UIColor(hex: "#333333") ?? .clear
    }

    static var textPrimary: UIColor {
        UIColor(hex: "#333333") ?? .clear
    }

    static var n3: UIColor {
        UIColor(hex: "#9299A2") ?? .clear
    }

    static var n7: UIColor {
        UIColor(hex: "#F6F7F8") ?? .clear
    }

    static var n8: UIColor {
        UIColor(hex: "#428BF9") ?? .clear
    }

    static var n14: UIColor {
        UIColor(hex: "#FFFFFF") ?? .clear
    }

    static var n15: UIColor {
        UIColor(hex: "#000000") ?? .clear
    }

    static var n16: UIColor {
        UIColor(hex: "#1C1C1E") ?? .clear
    }

    static var n18: UIColor {
        UIColor(hex: "#2C2C2E") ?? .clear
    }

    static var lightGray: UIColor {
        UIColor(hex: "#F7F7F7") ?? .clear
    }

    static var darkGray: UIColor {
        UIColor(hex: "#C7C9CC") ?? .clear
    }

    static var accent: UIColor {
        UIColor(hex: "#428BF9") ?? .clear
    }
}

// MARK: - Pallete

extension ASDKColors {

    // MARK: - Foreground

    struct Foreground {

        // Static

        static var brandTinkoffAccent: UIColor { UIColor(hex: "#FFDD2D") ?? .clear }
        static var negativeAccent: UIColor { UIColor(hex: "#F52222") ?? .clear }

        // Dynamic

        static var skeleton: UIColor.Dynamic {
            UIColor.Dynamic(
                light: .black.withAlphaComponent(0.03),
                dark: .white.withAlphaComponent(0.10)
            )
        }
    }

    // MARK: - Background

    struct Background {

        static var base: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.n14,
                dark: ASDKColors.n15
            )
        }

        static var elevation1: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.n14,
                dark: ASDKColors.n16
            )
        }

        static var elevation2: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.n14,
                dark: ASDKColors.n18
            )
        }

        static var elevation3: UIColor.Dynamic {
            UIColor.Dynamic(
                light: .white,
                dark: ASDKColors.black
            )
        }

        static var separator: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.darkGray,
                dark: ASDKColors.black
            )
        }

        static var highlight: UIColor.Dynamic {
            UIColor.Dynamic(
                light: UIColor(hex: "#00000014") ?? .clear,
                dark: UIColor(hex: "#FFFFFF1A") ?? .clear
            )
        }

        static var neutral1: UIColor.Dynamic {
            UIColor.Dynamic(
                light: UIColor(hex: "#001024")!.withAlphaComponent(0.03),
                dark: .white.withAlphaComponent(0.10)
            )
        }

        static var neutral2: UIColor.Dynamic {
            UIColor.Dynamic(
                light: UIColor(hex: "#001024")!.withAlphaComponent(0.06),
                dark: .white.withAlphaComponent(0.15)
            )
        }
    }

    // MARK: - Text

    struct Text {
        static var primary: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.textPrimary,
                dark: ASDKColors.n7
            )
        }

        static var primaryOnTinkoff: UIColor.Dynamic {
            UIColor.Dynamic(
                light: ASDKColors.textPrimary,
                dark: ASDKColors.textPrimary
            )
        }

        static var secondary: UIColor.Dynamic {
            UIColor.Dynamic(
                light: UIColor(hex: "#9299A2")!,
                dark: UIColor(hex: "#9299A2")!
            )
        }

        static var tertiary: UIColor.Dynamic {
            UIColor.Dynamic(
                light: UIColor(hex: "#001024")!.withAlphaComponent(0.22),
                dark: UIColor.white.withAlphaComponent(0.3)
            )
        }
    }

    // MARK: - Button

    struct Button {

        struct Sbp {
            static var background: UIColor.Dynamic {
                return UIColor.Dynamic(
                    light: .black,
                    dark: .white
                )
            }

            static var tint: UIColor.Dynamic {
                UIColor.Dynamic(
                    light: .white,
                    dark: .black
                )
            }
        }
    }
}
