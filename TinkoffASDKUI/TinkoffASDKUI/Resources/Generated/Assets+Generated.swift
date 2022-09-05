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
    internal static let emptyBanks = ImageAsset(name: "empty_banks")
  }
  internal enum TinkoffPay {
    internal static let tinkoffPayLogoBlack = ImageAsset(name: "tinkoff_pay_logo_black")
    internal static let tinkoffPayLogoWhite = ImageAsset(name: "tinkoff_pay_logo_white")
  }
  internal static let add = ImageAsset(name: "add")
  internal static let buttonIconSBP = ImageAsset(name: "buttonIconSBP")
  internal static let cancel = ImageAsset(name: "cancel")
  internal enum CardRequisites {
    internal static let maestroLogo = ImageAsset(name: "maestro_logo")
    internal static let mcLogo = ImageAsset(name: "mc_logo")
    internal static let mirLogo = ImageAsset(name: "mir_logo")
    internal static let visaLogo = ImageAsset(name: "visa_logo")
  }
  internal static let done = ImageAsset(name: "done")
  internal enum Illustrations {
    internal static let illustrationsCommonLightCard = ImageAsset(name: "illustrations-common-light-card")
  }
  internal static let logoPs = ImageAsset(name: "logo_ps")
  internal static let next = ImageAsset(name: "next")
  internal static let nexta = ImageAsset(name: "nexta")
  internal static let scan = ImageAsset(name: "scan")
  internal static let share = ImageAsset(name: "share")
  internal static let tick24 = ImageAsset(name: "tick_24")
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
