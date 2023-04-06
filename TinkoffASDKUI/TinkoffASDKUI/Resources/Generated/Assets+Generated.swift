// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Sbp {
    internal static let sbpAvatar = ImageAsset(name: "sbp-avatar")
    internal static let sbpLogoLight = ImageAsset(name: "sbp-logo-light")
    internal static let sbpLogoUniversal = ImageAsset(name: "sbp-logo-universal")
    internal static let sbpLogo = ImageAsset(name: "sbp_logo")
    internal static let sbpNoImage = ImageAsset(name: "sbp_no_image")
    internal static let sbpNoLogo = ImageAsset(name: "sbp_no_logo")
  }
  internal enum TinkoffPay {
    internal static let tinkoffPayAvatar = ImageAsset(name: "tinkoffPay-avatar")
    internal static let tinkoffPaySmallNoBorder = ImageAsset(name: "tinkoffPay-small-no-border")
    internal static let tinkoffPayLogoBlack = ImageAsset(name: "tinkoff_pay_logo_black")
    internal static let tinkoffPayLogoWhite = ImageAsset(name: "tinkoff_pay_logo_white")
  }
  internal static let cancel = ImageAsset(name: "cancel")
  internal enum CardRequisites {
    internal static let maestroLogo = ImageAsset(name: "maestro_logo")
    internal static let mcLogo = ImageAsset(name: "mc_logo")
    internal static let mirLogo = ImageAsset(name: "mir_logo")
    internal static let visaLogo = ImageAsset(name: "visa_logo")
  }
  internal static let done = ImageAsset(name: "done")
  internal enum Icons {
    internal static let addedCard = ImageAsset(name: "added-card")
    internal static let cardPlus = ImageAsset(name: "cardPlus")
    internal static let check = ImageAsset(name: "check")
    internal static let clear = ImageAsset(name: "clear")
    internal static let popupBar = ImageAsset(name: "popup-bar")
  }
  internal enum Illustrations {
    internal static let alarm = ImageAsset(name: "alarm")
    internal static let cardCross = ImageAsset(name: "card-cross")
    internal static let checkCirclePositive = ImageAsset(name: "check-circle-positive")
    internal static let crossCircle = ImageAsset(name: "cross-circle")
    internal static let illustrationsCommonLightCard = ImageAsset(name: "illustrations-common-light-card")
    internal static let wiFiOff = ImageAsset(name: "wi-fi-off")
  }
  internal enum Logo {
    internal static let smallGerb = ImageAsset(name: "small-gerb")
  }
  internal static let logoPs = ImageAsset(name: "logo_ps")
  internal static let next = ImageAsset(name: "next")
  internal static let nexta = ImageAsset(name: "nexta")
  internal enum PaymentCard {
    internal enum Bank {
      internal static let alpha = ImageAsset(name: "alpha")
      internal static let gazprom = ImageAsset(name: "gazprom")
      internal static let other = ImageAsset(name: "other")
      internal static let ozon = ImageAsset(name: "ozon")
      internal static let raiffaisen = ImageAsset(name: "raiffaisen")
      internal static let sber = ImageAsset(name: "sber")
      internal static let tinkoff = ImageAsset(name: "tinkoff")
      internal static let vtb = ImageAsset(name: "vtb")
    }
    internal static let cardFrontsideAvatar = ImageAsset(name: "card-frontside-avatar")
    internal enum PaymentSystem {
      internal static let maestro = ImageAsset(name: "maestro")
      internal static let mastercard = ImageAsset(name: "mastercard")
      internal static let mirWhite = ImageAsset(name: "mir-white")
      internal static let mir = ImageAsset(name: "mir")
      internal static let unionpay = ImageAsset(name: "unionpay")
      internal static let visaWhite = ImageAsset(name: "visa-white")
      internal static let visa = ImageAsset(name: "visa")
    }
  }
  internal static let scan = ImageAsset(name: "scan")
  internal static let scanCard = ImageAsset(name: "scan_card")
  internal static let share = ImageAsset(name: "share")
  internal static let tuiIcServiceCross24 = ImageAsset(name: "tui_ic_service_cross_24")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = Bundle.uiResources
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = Bundle.uiResources
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle.uiResources
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = Bundle.uiResources
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = Bundle.uiResources
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = Bundle.uiResources
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif
